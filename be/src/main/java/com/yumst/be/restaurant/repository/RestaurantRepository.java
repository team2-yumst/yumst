package com.yumst.be.restaurant.repository;

import com.yumst.be.restaurant.domain.Restaurant;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface RestaurantRepository extends JpaRepository<Restaurant, Long> {
    Optional<Restaurant> findByRestaurantId(String restaurantId);
    List<Restaurant> findTop10RestaurantsByCrawlCompleteTrue();
    boolean existsByRestaurantId(String restaurantId);

    @Query(value = """
        SELECT * FROM restaurant r
        WHERE ST_DWithin(
            geography(ST_SetSRID(ST_MakePoint(CAST(r.longitude AS float), CAST(r.latitude AS float)), 4326)),
            geography(ST_SetSRID(ST_MakePoint(:longitude, :latitude), 4326)),
            :radius * 1000
        )
        ORDER BY ST_Distance(
            geography(ST_SetSRID(ST_MakePoint(CAST(r.longitude AS float), CAST(r.latitude AS float)), 4326)),
            geography(ST_SetSRID(ST_MakePoint(:longitude, :latitude), 4326))
        )
        """, nativeQuery = true)
    Page<Restaurant> findNearbyRestaurants(
        @Param("latitude") Double latitude,
        @Param("longitude") Double longitude,
        @Param("radius") Double radius,
        Pageable pageable
    );
}