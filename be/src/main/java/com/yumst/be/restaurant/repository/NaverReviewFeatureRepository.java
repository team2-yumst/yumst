package com.yumst.be.restaurant.repository;

import com.yumst.be.restaurant.domain.NaverReviewFeature;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface NaverReviewFeatureRepository extends JpaRepository<NaverReviewFeature, Long> {
    Optional<NaverReviewFeature> findByFeature(String feature);
}
