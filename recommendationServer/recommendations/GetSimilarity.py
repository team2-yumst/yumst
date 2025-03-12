from django.http import JsonResponse
from sqlalchemy import create_engine
import pandas as pd
from sklearn.decomposition import PCA
from sklearn.metrics.pairwise import cosine_similarity

class SimilarityCalc:
    def __init__(self, userId, user_lat, user_long, db_url, isWalk):
        self.userId = userId
        self.user_lat = user_lat
        self.user_long = user_long
        self.db_url = db_url
        self.engine = create_engine(db_url)
        self.isWalk = isWalk
        self.user_preferences_columns = [
            "친절한 곳", "인테리어가 멋진 곳", "가성비 좋은 곳", "청결한 곳", "대화하기 좋은 곳", "단체 모임하기 좋은 곳", "주차하기 편한 곳", "넓은 곳", "뷰가 좋은 곳",
            "특별한 날 가기 좋은 곳",
            "혼밥하기 좋은 곳", "양이 많은 곳", "재료가 신선한 곳", "빨리 나오는 곳", "맛있는 곳",
            "커피가 맛있는 곳", "디저트가 맛있는 곳", "집중하기 좋은 곳", "좌석이 편한 곳", "오래 머무르기 좋은 곳"
        ]
        self.user_preferences_cols = [
            "친절해요", "인테리어가 멋져요", "가성비가 좋아요", "청결해요", "대화하기 좋아요", "단체모임하기 좋아요", "주차하기 편해요", "넓어요", "뷰가 좋아요",
            "특별한 날 가기 좋아요",
            "혼밥하기 좋아요", "양이 많아요", "재료가 신선해요", "빨리 나와요", "맛있어요",
            "커피가 맛있어요", "디저트가 맛있어요", "집중하기 좋아요", "좌석이 편해요", "오래 머무르기 좋아요"
        ]


    '''
        userId를 기반으로 사용자 feature extract
    '''
    def getUserPreference(self):
        # userId를 기반으로 쿼리 실행
        user_query = '''
            SELECT u.user_id, up.preference
            FROM user_preference up
            JOIN users u ON up.user_id = u.id
            WHERE u.user_id = %s;
        '''

        # pandas를 이용해 쿼리 실행하고 결과를 DataFrame으로 반환
        user_preferences = pd.read_sql(user_query, self.engine, params=(self.userId,))

        user_table = pd.DataFrame(columns=["user_id"] + self.user_preferences_columns)
        user_table.set_index("user_id", inplace=True)

        for idx, row in user_preferences.iterrows():
            user_id = row['user_id']
            preference = row['preference']

            if user_id not in user_table.index:
                new_row = {'user_id': user_id}
                user_table.loc[user_id] = new_row

                user_table.loc[user_id, :] = 0

            # preference 값에 +1
            if preference in user_table.columns:  # preference가 user_table에 존재하는 컬럼인지 확인
                user_table.loc[user_id, preference] += 1
            else:
                print(f"Preference '{preference}' does not exist in columns")

        return user_table

    def addUserRestaurantScrap(self, user_table, restaurant_table):

        user_restaurant_scrap_query = """
            SELECT u.user_id, r.restaurant_id
            FROM users u
            JOIN user_restaurant_scrap urs ON u.user_id = urs.user_id
            JOIN restaurant r ON urs.restaurant_id = r.restaurant_id
            WHERE u.user_id = %s;
        """

        # user_restaurant_scrap
        user_restaurant_scrap_table = pd.read_sql(user_restaurant_scrap_query, self.engine, params=(self.userId,))

        # restaurant_table과 user_restaurant_scrap_table을 조인
        scrap_table = pd.merge(user_restaurant_scrap_table, restaurant_table[['restaurant_id', 'feature', 'review_count']], on='restaurant_id')
        if scrap_table.empty:
            return user_table

        scrap_table_sorted = scrap_table.groupby('restaurant_id', group_keys=False).apply(lambda x: x.sort_values('review_count', ascending=False))
        top_5_scrap_features_table = scrap_table_sorted.groupby('restaurant_id').head(5)

        prefence_mapping = dict(zip(self.user_preferences_cols, self.user_preferences_columns))

        for idx, row in top_5_scrap_features_table.iterrows():
            user_id = row['user_id']
            feature = row['feature']

            if feature in self.user_preferences_cols:

                feature = prefence_mapping[feature]
                user_table.loc[user_id, feature] += 1

        return user_table

    def getRestaurantTable(self):

        user_lat = float(self.user_lat)
        user_long = float(self.user_long)

        # api가 walk이면 최대 3km, vehicle이면 10km
        if (self.isWalk):
            distance_threshold = 3000
        else:
            distance_threshold = 10000

        restaurant_query = '''
            WITH DistanceFiltered AS (
                SELECT 
                    r.restaurant_id,
                    r.name,
                    r.latitude,
                    r.longitude,
                    naver_review.feature,
                    naver_review.review_count,
                    earth_distance(
                        ll_to_earth(r.latitude::FLOAT, r.longitude::FLOAT),
                        ll_to_earth(%s::FLOAT, %s::FLOAT)
                    ) AS distance
                FROM restaurant r
                JOIN (
                    SELECT n.restaurant_id, nf.feature, n.review_count
                    FROM naver_review_feature nf
                    JOIN restaurant_naver_review_count n 
                    ON nf.id = n.naver_review_id
                ) AS naver_review
                ON r.restaurant_id = naver_review.restaurant_id
                WHERE r.crawl_complete = TRUE
            )
            SELECT 
                restaurant_id,
                name,
                latitude,
                longitude,
                feature,
                review_count,
                distance
            FROM DistanceFiltered
            WHERE distance <= %s
            ORDER BY restaurant_id;
        '''

        restaurant_table = pd.read_sql(restaurant_query, self.engine, params=(user_lat, user_long, distance_threshold))

        # 컬럼을 float으로 변환
        float_columns = ['longitude', 'latitude', 'distance']

        # 각 컬럼을 float 타입으로 변환
        restaurant_table[float_columns] = restaurant_table[float_columns].astype(float)

        return restaurant_table

    def getUserFeature(self):
        user_table = self.getUserPreference()
        restaurant_table = self.getRestaurantTable()
        user_table = self.addUserRestaurantScrap(user_table, restaurant_table)

        user_features = user_table.values

        return user_features, restaurant_table

    def getRecommedScore(self):
        user_features, restaurant_table = self.getUserFeature()
        if user_features.shape[0]==0:
            return JsonResponse({
                "status": "404 Not Found",
                "message": f"Empty Restaurant Feature"
            }, status=404)

        min_distance = restaurant_table['distance'].min()
        max_distance = restaurant_table['distance'].max()
        restaurant_feature_table = restaurant_table[['restaurant_id', 'name', 'feature', 'review_count']]
        restaurant_table = restaurant_table.set_index('restaurant_id')

        # Pivot을 사용해 feature를 컬럼으로 변환
        rt_pivot = restaurant_feature_table.pivot_table(index=['restaurant_id', 'name'], columns='feature', values='review_count', fill_value=0)

        # 컬럼명을 정리하고 reset_index
        restaurant_feature_table = rt_pivot.reset_index()
        restaurant_feature_table = restaurant_feature_table.set_index('restaurant_id')
        restaurant_features = restaurant_feature_table.drop(columns=['name']).values  # restaurant_df에서 feature들만 사용
        if restaurant_features.shape[0]==0:
            return JsonResponse({
                "status": "404 Not Found",
                "message": f"Empty Restaurant Feature"
            }, status=404)

        '''
        PCA를 통한 차원 축소
        '''
        pca = PCA(n_components=20)
        restaurant_features = pca.fit_transform(restaurant_features) # 오류 나면 user table의 user_id가 인덱스 설정 안되어 있는 것이므로 getUserFeature에서 설정하기

        similarity_matrix = cosine_similarity(user_features, restaurant_features)
        restaurant_feature_table['similarity'] = similarity_matrix[0]

        distance_table = restaurant_table[['distance']].groupby(restaurant_table.index).first()

        # index(restaurant_id)를 기준으로 join 수행
        restaurant_feature_table = restaurant_feature_table.join(distance_table, how='left')
        restaurant_feature_table = restaurant_feature_table.reset_index()

        # restaurant_id와 similarity 컬럼만 선택하여 recommend_table 생성
        recommend_table = restaurant_feature_table[['restaurant_id', 'name', 'similarity', 'distance']]

        if (self.isWalk):
            similarity_weight = 1
            distance_weight = 5
            total_weight = distance_weight + similarity_weight
        else:
            similarity_weight = 1
            distance_weight = 1
            total_weight = distance_weight + similarity_weight

        recommend_table['recommend_score'] = (recommend_table['similarity'] * similarity_weight + (1 - self.normalize_distance(recommend_table['distance'], min_distance, max_distance)) * distance_weight) / total_weight

        return recommend_table

    def normalize_distance(self, distance, min_distance, max_distance):

        # 거리가 동일하면 0으로 정규화
        if max_distance == min_distance:
            return 0

        return (distance - min_distance) / (max_distance - min_distance)