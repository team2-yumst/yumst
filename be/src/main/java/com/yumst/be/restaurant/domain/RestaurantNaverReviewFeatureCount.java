package com.yumst.be.restaurant.domain;

import com.yumst.be.global.entity.BaseTimeEntity;
import jakarta.persistence.*;

import static jakarta.persistence.GenerationType.IDENTITY;

@Entity
@Table(name = "restaurant_naver_review_count")
public class RestaurantNaverReviewFeatureCount extends BaseTimeEntity {

    @Id @GeneratedValue(strategy = IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String restaurantId;

    @JoinColumn(name = "naver_review_id")
    @ManyToOne(fetch = FetchType.LAZY)
    private NaverReviewFeature naverReviewFeature;

    private Long reviewCount;
}
