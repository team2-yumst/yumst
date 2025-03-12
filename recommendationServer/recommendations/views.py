from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny
from rest_framework.pagination import PageNumberPagination
from django.http import JsonResponse

from recommendations.GetSimilarity import SimilarityCalc

''''
PostgreSQL 연결 설정
'''
db_url = "postgresql+psycopg://postgres:1234@localhost:5432/yumst"

'''
페이지네이션 설정
'''
class RecommendationPagination(PageNumberPagination):
    page_size = 10
    page_size_query_param = 'page_size'
    max_page_size = 100

'''
추천 API view
'''

@api_view(['GET'])
@permission_classes([AllowAny])
def restaurant_recommendation_walk(request):
    try:
        # 헤더에서 user_id를 가져오기
        user_id = request.META.get('HTTP_USERID')  # HTTP_ 접두사와 대문자 사용
        if user_id is None:
            return JsonResponse({"error": "400 Bad Request", "message": "Missing required parameters(userId)"}, status=400)

        # 쿼리 파라미터에서 위도와 경도를 가져오기
        user_lat = request.GET.get('latitude')
        if user_lat is None:
            return JsonResponse({"error": "400 Bad Request", "message": "Missing required parameters(latitude)"},
                                status=400)

        user_long = request.GET.get('longitude')
        if user_long is None:
            return JsonResponse({"error": "400 Bad Request", "message": "Missing required parameters(longitude)"},
                                status=400)

        user_lat = float(user_lat)
        user_long = float(user_long)

        similarityCalc = SimilarityCalc(user_id, user_lat, user_long, db_url, isWalk=True)
        recommend_table = similarityCalc.getRecommedScore()
        print(recommend_table)
        if isinstance(recommend_table, JsonResponse):
            return recommend_table

        # recommend_score 컬럼을 기준으로 내림차순 정렬
        recommend_table_sorted = recommend_table.sort_values(by='recommend_score', ascending=False)

        top_restaurants = []
        for idx, row in recommend_table_sorted.iterrows():
            recommend = {
                'restaurant_id': row['restaurant_id'],
                'distance': row['distance'],
                'recommend_score': row['recommend_score']
            }
            top_restaurants.append(recommend)

        # 페이지네이션 적용
        paginator = RecommendationPagination()
        page = paginator.paginate_queryset(top_restaurants, request)
        return paginator.get_paginated_response(page)
    except Exception as e:
        # 예기치 않은 오류가 발생했을 경우 그 오류 메시지를 반환
        return JsonResponse({
            "status": "500 Internal Server Error",
            "message": f"An unexpected error occurred: {str(e)}"
        }, status=500)


@api_view(['GET'])
@permission_classes([AllowAny])
def restaurant_recommendation_vehicle(request):
    try:
        # 헤더에서 user_id를 가져오기
        user_id = request.META.get('HTTP_USERID')  # HTTP_ 접두사와 대문자 사용
        if user_id is None or user_id == '':
            return JsonResponse({"error": "400 Bad Request", "message": "Missing required parameters(userId)"}, status=400)

        # 쿼리 파라미터에서 위도와 경도를 가져오기
        user_lat = request.GET.get('latitude')
        if user_lat is None or user_lat == '':
            return JsonResponse({"error": "400 Bad Request", "message": "Missing required parameters(latitude)"}, status=400)

        user_long = request.GET.get('longitude')
        if user_long is None or user_long == '':
            return JsonResponse({"error": "400 Bad Request", "message": "Missing required parameters(longitude)"}, status=400)

        user_lat = float(user_lat)
        user_long = float(user_long)

        similarityCalc = SimilarityCalc(user_id, user_lat, user_long, db_url, isWalk=False)
        recommend_table = similarityCalc.getRecommedScore()
        if isinstance(recommend_table, JsonResponse):
            return recommend_table

        # recommend_score 컬럼을 기준으로 내림차순 정렬
        recommend_table_sorted = recommend_table.sort_values(by='recommend_score', ascending=False)

        top_restaurants = []
        for idx, row in recommend_table_sorted.iterrows():
            recommend = {
                'restaurant_id': row['restaurant_id'],
                'distance': row['distance'],
                'recommend_score': row['recommend_score']
            }
            top_restaurants.append(recommend)

        # 페이지네이션 적용
        paginator = RecommendationPagination()
        page = paginator.paginate_queryset(top_restaurants, request)
        return paginator.get_paginated_response(page)
    except Exception as e:
        # 예기치 않은 오류가 발생했을 경우 그 오류 메시지를 반환
        return JsonResponse({
            "status": "500 Internal Server Error",
            "message": f"An unexpected error occurred: {str(e)}"
        }, status=500)
