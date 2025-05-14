package com.yumst.be.user.repository;

import com.yumst.be.user.domain.UserRestaurantScrap;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface UserRestaurantScrapRepository extends JpaRepository<UserRestaurantScrap, Long> {
    Optional<UserRestaurantScrap> findByUserIdAndRestaurantId(String userId, String restaurantId);
    boolean existsByUserIdAndRestaurantId(String userId, String restaurantId);

    @Query("SELECT s.restaurantId " +
            "FROM UserRestaurantScrap s " +
            "WHERE s.userId = :userId " +
            "ORDER BY s.createdAt DESC")
    List<String> findAllRestaurantIdByUserId(String userId);

    @Query("""
        SELECT s.restaurantId 
        FROM UserRestaurantScrap s 
        WHERE s.userId = :userId 
        AND s.restaurantId IN :restaurantIds
    """)
    List<String> findScrappedRestaurantIds(@Param("userId") String userId, @Param("restaurantIds") List<String> restaurantIds);
}
