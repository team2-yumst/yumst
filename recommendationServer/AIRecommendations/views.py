from rest_framework.pagination import PageNumberPagination
from AIRecommendations.ProduceDF import ProduceDataFrame
from AIRecommendations.Inference import recommend_within_radius
from AIRecommendations.BaseRecommender import BaseRecommender
from AIRecommendations.UserEncoder import UserEncoder
from AIRecommendations.ProtoCF import ProtoCF

from django.http import JsonResponse
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny
from sqlalchemy import create_engine
import pandas as pd

import time
import os
import psutil



# DB URL
db_url = "postgresql+psycopg://postgres:1234@localhost:5432/yumst_db"
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
def restaurant_recommendation_ai(request):
    try:
        # 1. 사용자 정보 확인
        user_id = request.META.get('HTTP_USERID')
        if not user_id:
            return JsonResponse({"status": "400 Bad Request", "message": "Missing userId in header"}, status=400)

        user_lat = request.GET.get('latitude')
        user_long = request.GET.get('longitude')
        if not user_lat or not user_long:
            return JsonResponse({"status": "400 Bad Request", "message": "Missing latitude or longitude"}, status=400)

        user_lat = float(user_lat)
        user_long = float(user_long)

        # 2. 데이터 준비
        dataFrameProducer = ProduceDataFrame(db_url)
        user_df = dataFrameProducer.getFinalUserTable()
        rest_df = dataFrameProducer.getFinalRestaurantTable()

        if user_id not in user_df["user_id"].values:
            return JsonResponse({
                "status": "400 Bad Request",
                "message": f"User ID '{user_id}' not found in user_df"
            }, status=400)

        num_users = user_df['user_id'].nunique()
        num_items = rest_df['restaurant_id'].nunique()

        baserec = BaseRecommender(num_users, num_items, 128)
        userenc = UserEncoder(input_dim=user_df.shape[1] - 1)
        proto_cf = ProtoCF(
            base_rec=baserec,
            user_encoder=userenc,
            num_users=1,
            num_items=num_items,
            dim=128, M=50, K=2, Kq=1, tau=0.1, lambda_d=0.01
        )

        # 3. 추천 실행
        recommend_table = recommend_within_radius(user_id, user_df, rest_df, proto_cf, create_engine(db_url), user_lat, user_long, 3)

        if recommend_table.empty:
            return JsonResponse({"status": "204 No Content", "message": "No nearby recommended restaurants found."}, status=204)

        # 4. 결과 정리 및 응답
        recommend_table_sorted = recommend_table.sort_values(by='score', ascending=False)
        top_restaurants = [
            {
                'restaurant_id': row['restaurant_id'],
                'distance': row['distance_km'],
                'recommend_score': row['score']
            } for _, row in recommend_table_sorted.iterrows()
        ]

        paginator = RecommendationPagination()
        page = paginator.paginate_queryset(top_restaurants, request)
        return paginator.get_paginated_response(page)

    except ValueError as ve:
        return JsonResponse({
            "status": "400 Bad Request",
            "message": f"Invalid input: {str(ve)}"
        }, status=400)

    except KeyError as ke:
        return JsonResponse({
            "status": "500 Internal Server Error",
            "message": f"Missing expected data column: {str(ke)}"
        }, status=500)

    except Exception as e:
        return JsonResponse({
            "status": "500 Internal Server Error",
            "message": f"An unexpected error occurred: {str(e)}"
        }, status=500)

