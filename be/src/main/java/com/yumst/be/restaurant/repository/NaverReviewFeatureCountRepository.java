package com.yumst.be.restaurant.repository;

import com.yumst.be.restaurant.domain.RestaurantNaverReviewFeatureCount;
import org.springframework.data.jpa.repository.JpaRepository;

public interface NaverReviewFeatureCountRepository extends JpaRepository<RestaurantNaverReviewFeatureCount, Long> {
}
