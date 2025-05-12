package com.yumst.be.vote.domain;

import com.yumst.be.global.entity.BaseTimeEntity;
import com.yumst.be.vote.domain.VoteType;
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

    @Enumerated(EnumType.STRING)
    @Column(name = "vote_type", nullable = false)
    private VoteType voteType;
    
    @Version
    private Long version;

    @Builder
    public UserRestaurantVote(String userId, String restaurantId, VoteType voteType) {
        this.userId = userId;
        this.restaurantId = restaurantId;
        this.voteType = voteType;
    }

    public void updateVote(VoteType voteType) {
        this.voteType = voteType;
    }
}

