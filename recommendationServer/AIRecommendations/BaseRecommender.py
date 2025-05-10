import torch.nn as nn
class BaseRecommender(nn.Module):
    def __init__(self, num_users, num_items, dim):
        super().__init__()
        self.user_emb = nn.Embedding(num_users, dim)
        self.item_emb = nn.Embedding(num_items, dim)