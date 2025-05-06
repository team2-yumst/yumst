package com.yumst.be.restaurant.domain;

import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;

import static jakarta.persistence.GenerationType.IDENTITY;

@Entity
@Table(name = "naver_review_feature")
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@Getter
public class NaverReviewFeature {

    @Id @GeneratedValue(strategy = IDENTITY)
    private Long id;

    private String feature;

    public NaverReviewFeature(String feature) {
        this.feature = feature;
    }
}
