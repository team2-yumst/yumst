package com.yumst.be.recommendation.repository;

import com.yumst.be.recommendation.domain.RecommendationEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface RecommendationRepository extends JpaRepository<RecommendationEntity, UUID> {

    @Query(value = """
        WITH review_vectors AS (
            SELECT
                restaurant_id::UUID,
                ARRAY_AGG(COALESCE(review_count, 0)::REAL ORDER BY naver_review_id)::vector AS feature_vector
            FROM restaurant_naver_review_count
            GROUP BY restaurant_id
        ),
        user_vector AS (
            SELECT
                SUM(feature_vector)::vector AS user_pref_vector
            FROM (
                SELECT restaurant_id::UUID, 
                       ARRAY_AGG(COALESCE(review_count, 0)::REAL ORDER BY naver_review_id)::vector AS feature_vector
                FROM restaurant_naver_review_count
                WHERE restaurant_id IN (
                    SELECT restaurant_id FROM user_restaurant_scrap WHERE user_id::UUID = :userId
                )
                GROUP BY restaurant_id
            ) AS user_scrap_vectors
        )
        SELECT rv.restaurant_id::UUID
        FROM review_vectors rv
        CROSS JOIN user_vector
        ORDER BY (
            CAST('[' || array_to_string(
                rv.feature_vector::real[] || array_fill(0::REAL, ARRAY[
                    GREATEST(0, array_length(user_vector.user_pref_vector::real[], 1) - array_length(rv.feature_vector::real[], 1)) 
                ]), ',') || ']' AS vector)
            <#> 
            CAST('[' || array_to_string(
                user_vector.user_pref_vector::real[] || array_fill(0::REAL, ARRAY[
                    GREATEST(0, array_length(rv.feature_vector::real[], 1) - array_length(user_vector.user_pref_vector::real[], 1)) 
                ]), ',') || ']' AS vector)
        ) DESC
        LIMIT 10;
        """, nativeQuery = true)
    List<String> findRecommendations(@Param("userId") UUID userId);
}
