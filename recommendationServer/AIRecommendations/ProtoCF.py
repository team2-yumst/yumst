import torch
import torch.nn as nn
import torch.nn.functional as F

class ProtoCF(nn.Module):
    def __init__(self, base_rec, user_encoder, num_users, num_items,
                 dim=128, M=50, K=2, Kq=1, tau=0.1, lambda_d=0.01):
        super().__init__()
        self.base = base_rec
        self.user_encoder = user_encoder
        self.K, self.Kq = K, Kq
        self.user_enc = nn.Embedding(num_users, dim)
        self.user_enc.weight = nn.Parameter(base_rec.user_emb.weight.clone())
        self.group_z = nn.Parameter(torch.randn(M, dim))
        self.group_k = nn.Parameter(torch.randn(M, dim))
        self.Wq = nn.Linear(dim, dim, bias=False)
        self.Wg1 = nn.Linear(dim, dim)
        self.Wg2 = nn.Linear(dim, dim)
        self.bg = nn.Parameter(torch.zeros(dim))
        self.tau, self.lambda_d = tau, lambda_d

    def compute_prototype(self, support_u):
        u = self.user_enc(support_u)
        p = u.mean(dim=1)
        return F.normalize(p, dim=-1)

    def group_enhance(self, proto):
        Q = self.Wq(proto)
        att = (Q.unsqueeze(1) * self.group_k.unsqueeze(0)).sum(-1)
        alpha = F.softmax(att, dim=-1)
        g = alpha @ self.group_z
        return F.normalize(g, dim=-1)

    def gate(self, p, g):
        gate = torch.sigmoid(self.Wg1(p) + self.Wg2(g) + self.bg)
        return gate * p + (1 - gate) * g

    def distillation_loss(self, proto, items):
        hi = F.normalize(self.base.item_emb(items), dim=-1)
        P_teacher = F.softmax((hi @ hi.t()) / self.tau, dim=-1)
        P_student = F.softmax(proto @ proto.t(), dim=-1)
        return F.kl_div(P_student.log(), P_teacher, reduction='batchmean')

    def forward_episode(self, support_u, query_u, items):
        p = self.compute_prototype(support_u)
        g = self.group_enhance(p)
        e = self.gate(p, g)
        N, D = e.size(0), e.size(-1)
        q_emb = self.user_enc(query_u.view(-1)).view(-1, self.Kq, D)
        q_flat = q_emb.view(-1, D)
        scores = q_flat @ e.t()
        target = torch.arange(N, device=scores.device).repeat_interleave(self.Kq)
        Lp = F.cross_entropy(scores, target)
        Ld = self.distillation_loss(e, items)
        return Lp + self.lambda_d * Ld