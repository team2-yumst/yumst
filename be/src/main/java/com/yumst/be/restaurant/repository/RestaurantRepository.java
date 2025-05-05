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

    // 거리순 정렬
    @Query(value = 
        "WITH RankedRestaurants AS (" +
        "   SELECT " +
        "       r.restaurant_id, r.name, r.category, r.thumbnail_url, " +
        "       ST_Distance(" +
        "           geography(ST_SetSRID(ST_MakePoint(CAST(r.longitude AS float), CAST(r.latitude AS float)), 4326)), " +
        "           geography(ST_SetSRID(ST_MakePoint(:longitude, :latitude), 4326))" +
        "       ) as dist, " +
        "       COALESCE(bool_or(us.restaurant_id IS NOT NULL), false) as is_scrapped, " +
        "       COALESCE(SUM(CASE WHEN v.vote_type = 'LIKE' THEN 1 ELSE 0 END), 0) as like_count, " +
        "       COALESCE(SUM(CASE WHEN v.vote_type = 'DISLIKE' THEN 1 ELSE 0 END), 0) as dislike_count, " +
        "       ROW_NUMBER() OVER (PARTITION BY r.name ORDER BY ST_Distance(" +
        "           geography(ST_SetSRID(ST_MakePoint(CAST(r.longitude AS float), CAST(r.latitude AS float)), 4326)), " +
        "           geography(ST_SetSRID(ST_MakePoint(:longitude, :latitude), 4326)))" +
        "       ) as row_num " +
        "   FROM " +
        "       restaurant r " +
        "       LEFT JOIN user_restaurant_scrap us ON r.restaurant_id = us.restaurant_id AND us.user_id = :userId " +
        "       LEFT JOIN user_restaurant_vote v ON r.restaurant_id = v.restaurant_id " +
        "   WHERE " +
        "       r.crawl_complete = true AND " +
        "       ST_DWithin(" +
        "           geography(ST_SetSRID(ST_MakePoint(CAST(r.longitude AS float), CAST(r.latitude AS float)), 4326)), " +
        "           geography(ST_SetSRID(ST_MakePoint(:longitude, :latitude), 4326)), " +
        "           :radius * 1000" +
        "       ) " +
        "   GROUP BY r.restaurant_id, r.name, r.category, r.thumbnail_url, r.longitude, r.latitude" +
        ") " +
        "SELECT restaurant_id, name, category, thumbnail_url, dist, is_scrapped, like_count, dislike_count " +
        "FROM RankedRestaurants " +
        "WHERE row_num = 1 " +
        "ORDER BY dist ASC",
        countQuery = "SELECT COUNT(DISTINCT r.name) " +
                     "FROM restaurant r " +
                     "WHERE r.crawl_complete = true AND " +
                     "ST_DWithin(" +
                     "    geography(ST_SetSRID(ST_MakePoint(CAST(r.longitude AS float), CAST(r.latitude AS float)), 4326)), " +
                     "    geography(ST_SetSRID(ST_MakePoint(:longitude, :latitude), 4326)), " +
                     "    :radius * 1000" +
                     ")",
        nativeQuery = true)
    Page<Object[]> findNearbyRestaurantsOrderByDistance(
        @Param("userId") String userId,
        @Param("latitude") Double latitude,
        @Param("longitude") Double longitude,
        @Param("radius") Double radius,
        Pageable pageable
    );

    // 좋아요순 정렬
    @Query(value = 
        "WITH RankedRestaurants AS (" +
        "   SELECT " +
        "       r.restaurant_id, r.name, r.category, r.thumbnail_url, " +
        "       ST_Distance(" +
        "           geography(ST_SetSRID(ST_MakePoint(CAST(r.longitude AS float), CAST(r.latitude AS float)), 4326)), " +
        "           geography(ST_SetSRID(ST_MakePoint(:longitude, :latitude), 4326))" +
        "       ) as dist, " +
        "       COALESCE(bool_or(us.restaurant_id IS NOT NULL), false) as is_scrapped, " +
        "       COALESCE(SUM(CASE WHEN v.vote_type = 'LIKE' THEN 1 ELSE 0 END), 0) as like_count, " +
        "       COALESCE(SUM(CASE WHEN v.vote_type = 'DISLIKE' THEN 1 ELSE 0 END), 0) as dislike_count, " +
        "       ROW_NUMBER() OVER (PARTITION BY r.name ORDER BY ST_Distance(" +
        "           geography(ST_SetSRID(ST_MakePoint(CAST(r.longitude AS float), CAST(r.latitude AS float)), 4326)), " +
        "           geography(ST_SetSRID(ST_MakePoint(:longitude, :latitude), 4326)))" +
        "       ) as row_num " +
        "   FROM " +
        "       restaurant r " +
        "       LEFT JOIN user_restaurant_scrap us ON r.restaurant_id = us.restaurant_id AND us.user_id = :userId " +
        "       LEFT JOIN user_restaurant_vote v ON r.restaurant_id = v.restaurant_id " +
        "   WHERE " +
        "       r.crawl_complete = true AND " +
        "       ST_DWithin(" +
        "           geography(ST_SetSRID(ST_MakePoint(CAST(r.longitude AS float), CAST(r.latitude AS float)), 4326)), " +
        "           geography(ST_SetSRID(ST_MakePoint(:longitude, :latitude), 4326)), " +
        "           :radius * 1000" +
        "       ) " +
        "   GROUP BY r.restaurant_id, r.name, r.category, r.thumbnail_url, r.longitude, r.latitude" +
        ") " +
        "SELECT restaurant_id, name, category, thumbnail_url, dist, is_scrapped, like_count, dislike_count " +
        "FROM RankedRestaurants " +
        "WHERE row_num = 1 " +
        "ORDER BY like_count DESC, dist ASC",
        countQuery = "SELECT COUNT(DISTINCT r.name) " +
                     "FROM restaurant r " +
                     "WHERE r.crawl_complete = true AND " +
                     "ST_DWithin(" +
                     "    geography(ST_SetSRID(ST_MakePoint(CAST(r.longitude AS float), CAST(r.latitude AS float)), 4326)), " +
                     "    geography(ST_SetSRID(ST_MakePoint(:longitude, :latitude), 4326)), " +
                     "    :radius * 1000" +
                     ")",
        nativeQuery = true)
    Page<Object[]> findNearbyRestaurantsOrderByLikes(
        @Param("userId") String userId,
        @Param("latitude") Double latitude,
        @Param("longitude") Double longitude,
        @Param("radius") Double radius,
        Pageable pageable
    );

    // 싫어요순 정렬
    @Query(value = 
        "WITH RankedRestaurants AS (" +
        "   SELECT " +
        "       r.restaurant_id, r.name, r.category, r.thumbnail_url, " +
        "       ST_Distance(" +
        "           geography(ST_SetSRID(ST_MakePoint(CAST(r.longitude AS float), CAST(r.latitude AS float)), 4326)), " +
        "           geography(ST_SetSRID(ST_MakePoint(:longitude, :latitude), 4326))" +
        "       ) as dist, " +
        "       COALESCE(bool_or(us.restaurant_id IS NOT NULL), false) as is_scrapped, " +
        "       COALESCE(SUM(CASE WHEN v.vote_type = 'LIKE' THEN 1 ELSE 0 END), 0) as like_count, " +
        "       COALESCE(SUM(CASE WHEN v.vote_type = 'DISLIKE' THEN 1 ELSE 0 END), 0) as dislike_count, " +
        "       ROW_NUMBER() OVER (PARTITION BY r.name ORDER BY ST_Distance(" +
        "           geography(ST_SetSRID(ST_MakePoint(CAST(r.longitude AS float), CAST(r.latitude AS float)), 4326)), " +
        "           geography(ST_SetSRID(ST_MakePoint(:longitude, :latitude), 4326)))" +
        "       ) as row_num " +
        "   FROM " +
        "       restaurant r " +
        "       LEFT JOIN user_restaurant_scrap us ON r.restaurant_id = us.restaurant_id AND us.user_id = :userId " +
        "       LEFT JOIN user_restaurant_vote v ON r.restaurant_id = v.restaurant_id " +
        "   WHERE " +
        "       r.crawl_complete = true AND " +
        "       ST_DWithin(" +
        "           geography(ST_SetSRID(ST_MakePoint(CAST(r.longitude AS float), CAST(r.latitude AS float)), 4326)), " +
        "           geography(ST_SetSRID(ST_MakePoint(:longitude, :latitude), 4326)), " +
        "           :radius * 1000" +
        "       ) " +
        "   GROUP BY r.restaurant_id, r.name, r.category, r.thumbnail_url, r.longitude, r.latitude" +
        ") " +
        "SELECT restaurant_id, name, category, thumbnail_url, dist, is_scrapped, like_count, dislike_count " +
        "FROM RankedRestaurants " +
        "WHERE row_num = 1 " +
        "ORDER BY dislike_count DESC, dist ASC",
        countQuery = "SELECT COUNT(DISTINCT r.name) " +
                     "FROM restaurant r " +
                     "WHERE r.crawl_complete = true AND " +
                     "ST_DWithin(" +
                     "    geography(ST_SetSRID(ST_MakePoint(CAST(r.longitude AS float), CAST(r.latitude AS float)), 4326)), " +
                     "    geography(ST_SetSRID(ST_MakePoint(:longitude, :latitude), 4326)), " +
                     "    :radius * 1000" +
                     ")",
        nativeQuery = true)
    Page<Object[]> findNearbyRestaurantsOrderByDislikes(
        @Param("userId") String userId,
        @Param("latitude") Double latitude,
        @Param("longitude") Double longitude,
        @Param("radius") Double radius,
        Pageable pageable
    );
    
    @Query(
                    "SELECT r " +
                    "FROM Restaurant r " +
                    "WHERE r.crawlComplete = true " +
                    "ORDER BY r.naverInformation.rating DESC " +
                    "LIMIT 10"
    )
    List<Restaurant> findTop10RestaurantsByCrawlCompleteTrueOrderByNaverInformation();

    Restaurant findFirstByOpenDataInformation_BusinessNameContainingAndOpenDataInformation_FullAddressContaining(String businessName, String fullAddress);
}

