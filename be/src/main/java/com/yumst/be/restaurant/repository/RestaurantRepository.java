package com.yumst.be.restaurant.repository;

import com.yumst.be.restaurant.domain.Restaurant;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Optional;

public interface RestaurantRepository extends JpaRepository<Restaurant, Long> {
    Optional<Restaurant> findByRestaurantId(String restaurantId);
    List<Restaurant> findTop10RestaurantsByCrawlCompleteTrue();
    @Query(
                    "SELECT r " +
                    "FROM Restaurant r " +
                    "WHERE r.crawlComplete = true " +
//                            "r.naverInformation.name like concat('%', '쭈꾸미블루스', '%') " +
                    "ORDER BY r.naverInformation.rating DESC " +
                    "LIMIT 10"
    )
    List<Restaurant> findTop10RestaurantsByCrawlCompleteTrueOrderByNaverInformation();
}
