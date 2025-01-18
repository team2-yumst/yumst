package com.yumst.be.restaurant.domain;

import jakarta.persistence.*;

import static jakarta.persistence.GenerationType.IDENTITY;

@Entity
@Table(name = "naver_review")
public class NaverReviewFeature {

    @Id @GeneratedValue(strategy = IDENTITY)
    private Long id;

    private String feature;

}
