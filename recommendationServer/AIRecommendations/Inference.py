import pandas as pd
import torch
import torch.nn.functional as F
from sqlalchemy import text

def recommend_within_radius(user_id, user_df, rest_df, proto_cf, engine, user_lat, user_long, radius_km=3):
    row = user_df[user_df["user_id"] == user_id]

    # user_id 컬럼 제외 후 tensor로 변환
    user_tensor = torch.tensor(row.drop(columns="user_id").values, dtype=torch.float32)

    # --- 사용자 임베딩 생성 ---
    user_embedding = proto_cf.user_encoder(user_tensor)
    user_embedding = F.normalize(user_embedding, dim=-1)

    # --- 모든 식당 임베딩 가져오기 ---
    item_embedding = F.normalize(proto_cf.base.item_emb.weight, dim=-1)

    # --- 추천 점수 계산 ---
    scores = (user_embedding @ item_embedding.t()).squeeze().detach().cpu().numpy()

    # --- restaurant_id 매핑 (item_id <-> restaurant_id) ---
    restaurant_df = rest_df
    restaurant_df["score"] = scores

    # --- 거리 계산 ---
    distance_query = text("""
        SELECT restaurant_id,
               earth_distance(
                   ll_to_earth(:user_lat, :user_long),
                   ll_to_earth(latitude::float8, longitude::float8)
               ) AS distance_m
        FROM restaurant r
        WHERE r.crawl_complete = TRUE
    """)

    distance_df = pd.read_sql(distance_query, engine, params={"user_lat": user_lat, "user_long": user_long})
    distance_df["distance_km"] = distance_df["distance_m"] / 1000

    # --- 병합 + 필터링 ---
    merged_df = pd.merge(restaurant_df, distance_df, on="restaurant_id")
    filtered_df = merged_df[merged_df["distance_km"] <= radius_km]

    # --- 결과 반환 ---
    result_df = filtered_df[["restaurant_id", "score"]].sort_values(by="score", ascending=False).reset_index(drop=True)
    return result_df

