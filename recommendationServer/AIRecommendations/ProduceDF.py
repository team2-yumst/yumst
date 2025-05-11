from django.http import JsonResponse
from sqlalchemy import create_engine
import pandas as pd


class ProduceDataFrame:
    def __init__(self, db_url):
        self.db_url = db_url
        self.engine = create_engine(db_url)
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
        user table 생성
    '''
    def getUserTable(self):
        try:
            user_query = '''
                SELECT u.user_id, up.preference
                FROM user_preference up
                JOIN users u ON up.user_id = u.id;
            '''
            user_preferences = pd.read_sql(user_query, self.engine)

            user_table = pd.crosstab(
                user_preferences['user_id'],
                user_preferences['preference']
            )

            for col in self.user_preferences_columns:
                if col not in user_table.columns:
                    user_table[col] = 0
            user_table = user_table[self.user_preferences_columns]

            return user_table
        except Exception as e:
            return JsonResponse({
                "status": "500 Internal Server Error",
                "message": f"Failed to generate user table: {str(e)}"
            }, status=500)

    '''
        스크랩한 식당들의 상위 5개 특징들 사용자 특징 점수에 추가(특징이 중복되는 경우에만)
        - 스크랩한 경우 +3
    '''
    def addUserRestaurantScrap(self, user_table, restaurant_table):
        # 1) 모든 유저의 스크랩 데이터 가져오기 (WHERE 절 제거)
        user_restaurant_scrap_query = """
            SELECT u.user_id, urs.restaurant_id
            FROM users u
            JOIN user_restaurant_scrap urs 
              ON u.user_id = urs.user_id
            JOIN restaurant r 
              ON urs.restaurant_id = r.restaurant_id
            WHERE r.crawl_complete = TRUE
        """
        scrap_table = pd.read_sql(user_restaurant_scrap_query, self.engine)

        # 2) 식당 테이블과 조인하여 feature, review_count 추가
        scrap_table = pd.merge(
            scrap_table,
            restaurant_table[['restaurant_id', 'feature', 'review_count']],
            on='restaurant_id'
        )
        if scrap_table.empty:
            return user_table

        # 3) (user_id, restaurant_id)별로 review_count 내림차순 정렬 후 각 그룹 상위 5개
        scrap_sorted = (
            scrap_table
            .groupby(['user_id', 'restaurant_id'], group_keys=False)
            .apply(lambda df: df.sort_values('review_count', ascending=False))
        )
        top5 = scrap_sorted.groupby(['user_id', 'restaurant_id']).head(5)

        # 4) 컬럼 매핑 준비
        mapping = dict(zip(self.user_preferences_cols, self.user_preferences_columns))

        # 5) 결과를 user_table에 반영
        for _, row in top5.iterrows():
            uid = row['user_id']
            feature = row['feature']
            if feature in self.user_preferences_cols:
                col = mapping[feature]
                user_table.loc[uid, col] += 3

        return user_table

    """
        투표한 식당들의 상위 5개 특징들 사용자 특징 점수에 반영(특징이 중복되는 경우에만)
        - LIKE이면 +5
        - DISLIKE이면 -5
    """

    def addUserRestaurantVote(self, user_table, restaurant_table):
        try:
            user_restaurant_vote_query = """
                SELECT 
                    u.user_id, 
                    urv.restaurant_id, 
                    urv.vote_type
                FROM users u
                JOIN user_restaurant_vote urv 
                  ON u.user_id = urv.user_id
                JOIN restaurant r 
                  ON urv.restaurant_id = r.restaurant_id
                WHERE r.crawl_complete = TRUE
            """
            vote_table = pd.read_sql(user_restaurant_vote_query, self.engine)

            vote_table = pd.merge(
                vote_table,
                restaurant_table[['restaurant_id', 'feature', 'review_count']],
                on='restaurant_id'
            )
            if vote_table.empty:
                return user_table

            vote_sorted = vote_table.groupby(
                ['user_id', 'restaurant_id'],
                group_keys=False
            ).apply(lambda df: df.sort_values('review_count', ascending=False))
            top5 = vote_sorted.groupby(['user_id', 'restaurant_id']).head(5)

            mapping = dict(zip(self.user_preferences_cols, self.user_preferences_columns))

            for _, row in top5.iterrows():
                uid, feature, vote_type = row['user_id'], row['feature'], row['vote_type']
                if feature in self.user_preferences_cols:
                    col = mapping[feature]
                    if vote_type == 'LIKE':
                        user_table.loc[uid, col] += 5
                    elif vote_type == 'DISLIKE':
                        user_table.loc[uid, col] -= 5
                    else:
                        return JsonResponse({
                            "status": "error",
                            "message": f"Wrong vote type: {vote_type}"
                        }, status=400)

            return user_table
        except Exception as e:
            return JsonResponse({
                "status": "500 Internal Server Error",
                "message": f"Error in vote reflection: {str(e)}"
            }, status=500)

    def getRestaurantTable(self):
        try:
            restaurant_query = """
                SELECT
                    r.restaurant_id,
                    r.name,
                    nr.feature,
                    nr.review_count
                FROM restaurant r
                JOIN (
                    SELECT
                        n.restaurant_id,
                        nf.feature,
                        n.review_count
                    FROM naver_review_feature nf
                    JOIN restaurant_naver_review_count n
                      ON nf.id = n.naver_review_id
                ) AS nr
                  ON r.restaurant_id = nr.restaurant_id
                WHERE r.crawl_complete = TRUE
                ORDER BY r.restaurant_id;
            """
            restaurant_table = pd.read_sql(restaurant_query, self.engine)
            return restaurant_table
        except Exception as e:
            return JsonResponse({
                "status": "500 Internal Server Error",
                "message": f"Error loading restaurant table: {str(e)}"
            }, status=500)

    def transformRestaurantTable(self, restaurant_table):

        # 1) 피벗 테이블 생성: index=['restaurant_id','name'], columns=feature, values=review_count
        pivoted_restaurant_table = restaurant_table.pivot_table(
            index=['restaurant_id', 'name'],
            columns='feature',
            values='review_count',
            aggfunc='sum',
            fill_value=0
        ).reset_index()

        # 2) 멀티인덱스 컬럼명 제거 및 문자열화
        pivoted_restaurant_table.columns.name = None
        pivoted_restaurant_table.columns = [str(col) for col in pivoted_restaurant_table.columns]
        return pivoted_restaurant_table

    def getReviewTable(self):
        scrap_sql = "SELECT user_id, restaurant_id, 3 AS score FROM user_restaurant_scrap"
        vote_sql = """
            SELECT user_id, restaurant_id,
                CASE vote_type
                    WHEN 'LIKE' THEN  5
                    WHEN 'DISLIKE' THEN -5
                    ELSE 0
                END AS score
            FROM user_restaurant_vote
        """
        scrap_df = pd.read_sql(scrap_sql, self.engine)
        vote_df = pd.read_sql(vote_sql, self.engine)
        combined = pd.concat([scrap_df, vote_df], ignore_index=True)

        # 피봇 테이블 생성
        score_matrix = combined.pivot_table(
            index='user_id',
            columns='restaurant_id',
            values='score',
            aggfunc='sum',
            fill_value=0
        )

        # 모든 사용자 ID 가져오기
        all_users_df = pd.read_sql("SELECT DISTINCT user_id FROM users;", self.engine)
        all_users = all_users_df['user_id'].astype(str).tolist()

        # → 누락된 사용자까지 포함하도록 reindex
        score_matrix = score_matrix.reindex(index=all_users, fill_value=0)

        return score_matrix

    def getFinalUserTable(self):
        try:
            init_userTable = self.getUserTable()
            init_restaurantTable = self.getRestaurantTable()
            scrap_addedUserTable = self.addUserRestaurantScrap(init_userTable, init_restaurantTable)
            vote_addedUserTable = self.addUserRestaurantVote(scrap_addedUserTable, init_restaurantTable)
            vote_addedUserTable.reset_index(inplace=True)
            return vote_addedUserTable
        except Exception as e:
            return JsonResponse({
                "status": "500 Internal Server Error",
                "message": f"Error building final user table: {str(e)}"
            }, status=500)

    def getFinalRestaurantTable(self):
        init_restaurantTable = self.getRestaurantTable()
        restaurtTable = self.transformRestaurantTable(init_restaurantTable)
        return restaurtTable

    def getFinalReviewTable(self):
        init_reviewTable = self.getReviewTable()
        init_reviewTable.reset_index(inplace=True)
        return init_reviewTable
