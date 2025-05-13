from collections import defaultdict
from AIRecommendations.ProduceDF import ProduceDataFrame
from AIRecommendations.UserEncoder import UserEncoder
from AIRecommendations.BaseRecommender import BaseRecommender
from AIRecommendations.ProtoCF import ProtoCF
import torch
import random
import os

# DB URL
db_url = "postgresql+psycopg://postgres:1234@localhost:5432/yumst_db"


'''
Produce Dataframes
    - user_df: user dataset
    - rest_df: restaurant dataset
    - review_df: review dataset
'''
dataFrameProducer = ProduceDataFrame(db_url)
user_df = dataFrameProducer.getFinalUserTable()
rest_df = dataFrameProducer.getFinalRestaurantTable()
review_df = dataFrameProducer.getFinalReviewTable()

'''
Preprocessing
'''

# Melt review_df
melted = review_df.melt(
    id_vars=['user_id'],
    var_name='restaurant_id',
    value_name='score'
)

# Setting Thresholds
LIKE_THRESHOLD = 1
DISLIKE_THRESHOLD = -1

# Split melted
pos_df = melted[melted['score'] >= LIKE_THRESHOLD]
neg_df = melted[melted['score'] <= DISLIKE_THRESHOLD]

user_ids = sorted(user_df['user_id'].unique())
user2idx = {u: i for i, u in enumerate(user_ids)}
num_users = len(user2idx)

rest_ids = sorted(rest_df['restaurant_id'].astype(str).unique())
rest2idx = {rid: i for i, rid in enumerate(rest_ids)}
num_items = len(rest2idx)

user_pos = defaultdict(list)
user_neg = defaultdict(list)

for _, r in pos_df.iterrows():
    u, rid = r['user_id'], str(r['restaurant_id'])
    if u in user2idx and rid in rest2idx:
        user_pos[user2idx[u]].append(rest2idx[rid])

for _, r in neg_df.iterrows():
    u, rid = r['user_id'], str(r['restaurant_id'])
    if u in user2idx and rid in rest2idx:
        user_neg[user2idx[u]].append(rest2idx[rid])

user_item_dict = {i: [] for i in range(num_items)}
for u_idx, items in user_pos.items():
    for i_idx in items:
        user_item_dict[i_idx].append(u_idx)

def meta_train(proto_cf, user_item_dict, epochs=10, tasks_per_epoch=100, N=10, save_path='./Model/cand_model.pth'):
    optim = torch.optim.Adam(proto_cf.parameters(), lr=1e-3)
    best_loss = float('inf')
    os.makedirs(os.path.dirname(save_path), exist_ok=True)

    valid_items = [i for i, us in user_item_dict.items() if len(us) >= proto_cf.K + proto_cf.Kq]
    if not valid_items:
        return
    N_eff = min(N, len(valid_items))

    for epoch in range(epochs):
        epoch_loss = 0.0
        for _ in range(tasks_per_epoch):
            items_N = random.sample(valid_items, N_eff)
            support_u, query_u = [], []
            for i in items_N:
                users = user_item_dict[i]
                if len(users) < proto_cf.K + proto_cf.Kq:
                    continue
                samp = random.sample(users, proto_cf.K + proto_cf.Kq)
                support_u.append(samp[:proto_cf.K])
                query_u.append(samp[proto_cf.K:])
            if not support_u:
                continue
            s = torch.tensor(support_u, dtype=torch.long)
            q = torch.tensor(query_u, dtype=torch.long)
            idx = torch.tensor(items_N[:len(support_u)], dtype=torch.long)
            loss = proto_cf.forward_episode(s, q, idx)
            optim.zero_grad(); loss.backward(); optim.step()
            epoch_loss += loss.item()

        avg_loss = epoch_loss / tasks_per_epoch

        # Save Model
        if avg_loss < best_loss:
            best_loss = avg_loss
            torch.save(proto_cf.state_dict(), save_path)
            if best_loss < 1.3:
                torch.save(proto_cf.state_dict(), './Model/best_model.pth')



input_dim = user_df.shape[1] - 1  # user_id 제외
user_encoder = UserEncoder(input_dim=input_dim)
base = BaseRecommender(num_users, num_items, dim=128)
proto = ProtoCF(base, user_encoder, num_users, num_items, K=5, Kq=20)

meta_train(proto, user_item_dict, epochs=200, tasks_per_epoch=100, N=5)
