package com.yumst.be.restaurant.repository;

import com.yumst.be.restaurant.domain.Restaurant;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface RestaurantRepository extends JpaRepository<Restaurant, Long> {
    Optional<Restaurant> findByRestaurantId(String restaurantId);
    List<Restaurant> findTop10RestaurantsByCrawlCompleteTrue();
}
