package com.yumst.be.vote.domain;

import com.yumst.be.global.entity.BaseTimeEntity;
import com.yumst.be.vote.dto.VoteType;
import jakarta.persistence.*;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import static jakarta.persistence.GenerationType.IDENTITY;
import static lombok.AccessLevel.PROTECTED;

@Entity
@Table(name = "user_restaurant_vote")
@Getter
@NoArgsConstructor(access = PROTECTED)
public class UserRestaurantVote extends BaseTimeEntity {

    @Id @GeneratedValue(strategy = IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String userId;

    @Column(nullable = false)
    private String restaurantId;

    @Column(name = "is_like", nullable = false)
    private Boolean isLike;

    @Enumerated(EnumType.STRING)
    @Column(name = "vote_type", nullable = false)
    private VoteType voteType;

    @Builder
    public UserRestaurantVote(String userId, String restaurantId, VoteType voteType) {
        this.userId = userId;
        this.restaurantId = restaurantId;
        this.voteType = voteType;
        this.isLike = voteType == VoteType.LIKE;
    }

    public void updateVote(VoteType voteType) {
        this.voteType = voteType;
        this.isLike = voteType == VoteType.LIKE;
    }

    public VoteType getVoteType() {
        return isLike ? VoteType.LIKE : VoteType.DISLIKE;
    }
}
