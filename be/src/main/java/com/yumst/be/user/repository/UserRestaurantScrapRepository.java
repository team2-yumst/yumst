package com.yumst.be.user.repository;

import com.yumst.be.user.domain.UserRestaurantScrap;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface UserRestaurantScrapRepository extends JpaRepository<UserRestaurantScrap, Long> {
    Optional<UserRestaurantScrap> findByUserIdAndRestaurantId(String userId, String restaurantId);
}
