package com.yumst.be.restaurant.repository;

import com.yumst.be.restaurant.domain.NaverReviewFeature;
import org.springframework.data.jpa.repository.JpaRepository;

public interface NaverReviewRepository extends JpaRepository<NaverReviewFeature, Long> {

}
