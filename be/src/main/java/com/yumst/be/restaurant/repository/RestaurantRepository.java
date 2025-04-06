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

    // Base SELECT, FROM, WHERE clauses (reused in count queries)
    String BASE_NEARBY_SELECT = "SELECT r.restaurant_id, r.name, r.category, r.thumbnail_url, " +
            "ST_Distance(" +
            "    geography(ST_SetSRID(ST_MakePoint(CAST(r.longitude AS float), CAST(r.latitude AS float)), 4326))," +
            "    geography(ST_SetSRID(ST_MakePoint(:longitude, :latitude), 4326))" +
            ") as dist," +
            "COALESCE(bool_or(us.restaurant_id IS NOT NULL), false) as is_scrapped," +
            "COALESCE(SUM(CASE WHEN v.vote_type = 'LIKE' THEN 1 ELSE 0 END), 0) as like_count," +
            "COALESCE(SUM(CASE WHEN v.vote_type = 'DISLIKE' THEN 1 ELSE 0 END), 0) as dislike_count ";
    String BASE_NEARBY_FROM_WHERE = "FROM restaurant r " +
            "LEFT JOIN user_restaurant_scrap us ON r.restaurant_id = us.restaurant_id AND us.user_id = :userId " +
            "LEFT JOIN user_restaurant_vote v ON r.restaurant_id = v.restaurant_id " +
            "WHERE ST_DWithin(" +
            "    geography(ST_SetSRID(ST_MakePoint(CAST(r.longitude AS float), CAST(r.latitude AS float)), 4326))," +
            "    geography(ST_SetSRID(ST_MakePoint(:longitude, :latitude), 4326))," +
            "    :radius * 1000" +
            ") ";
    String BASE_NEARBY_GROUP_BY = "GROUP BY r.restaurant_id, r.name, r.category, r.thumbnail_url, r.longitude, r.latitude "; // Group by includes all non-aggregated selected columns + primary key for correctness

    String COUNT_QUERY_NEARBY = "SELECT COUNT(DISTINCT r.restaurant_id) " + BASE_NEARBY_FROM_WHERE; // Count distinct restaurants matching criteria


    // 거리순 정렬 (기존 메소드 이름 변경)
    @Query(value = BASE_NEARBY_SELECT + BASE_NEARBY_FROM_WHERE + BASE_NEARBY_GROUP_BY + "ORDER BY dist ASC",
           countQuery = COUNT_QUERY_NEARBY,
           nativeQuery = true)
    Page<Object[]> findNearbyRestaurantsOrderByDistance(
        @Param("userId") String userId,
        @Param("latitude") Double latitude,
        @Param("longitude") Double longitude,
        @Param("radius") Double radius,
        Pageable pageable
    );

    // 좋아요순 정렬
    @Query(value = BASE_NEARBY_SELECT + BASE_NEARBY_FROM_WHERE + BASE_NEARBY_GROUP_BY + "ORDER BY like_count DESC, dist ASC",
           countQuery = COUNT_QUERY_NEARBY,
           nativeQuery = true)
    Page<Object[]> findNearbyRestaurantsOrderByLikes(
        @Param("userId") String userId,
        @Param("latitude") Double latitude,
        @Param("longitude") Double longitude,
        @Param("radius") Double radius,
        Pageable pageable
    );

    // 싫어요순 정렬
    @Query(value = BASE_NEARBY_SELECT + BASE_NEARBY_FROM_WHERE + BASE_NEARBY_GROUP_BY + "ORDER BY dislike_count DESC, dist ASC",
           countQuery = COUNT_QUERY_NEARBY,
           nativeQuery = true)
    Page<Object[]> findNearbyRestaurantsOrderByDislikes(
        @Param("userId") String userId,
        @Param("latitude") Double latitude,
        @Param("longitude") Double longitude,
        @Param("radius") Double radius,
        Pageable pageable
    );
}