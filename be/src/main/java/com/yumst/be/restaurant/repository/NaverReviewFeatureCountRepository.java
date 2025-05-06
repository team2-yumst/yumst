package com.yumst.be.restaurant.repository;

import com.yumst.be.restaurant.domain.RestaurantNaverReviewFeatureCount;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;

public interface NaverReviewFeatureCountRepository extends JpaRepository<RestaurantNaverReviewFeatureCount, Long> {

    @Query("SELECT r " +
            "FROM RestaurantNaverReviewFeatureCount r " +
            "JOIN FETCH r.naverReviewFeature " +
            "WHERE r.restaurantId = :restaurantId " +
            "ORDER BY r.reviewCount DESC " +
            "LIMIT 2")
    List<RestaurantNaverReviewFeatureCount> findTop2ByRestaurantIdOrderByReviewCountDesc(String restaurantId);
}
