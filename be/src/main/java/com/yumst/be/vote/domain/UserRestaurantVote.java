package com.yumst.be.vote.domain;

import com.yumst.be.global.entity.BaseTimeEntity;
import jakarta.persistence.*;

import static jakarta.persistence.GenerationType.IDENTITY;

@Entity
@Table(name = "user_restaurant_vote")
public class UserRestaurantVote extends BaseTimeEntity {

    @Id @GeneratedValue(strategy = IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String userId;

    @Column(nullable = false)
    private String restaurantId;
}
