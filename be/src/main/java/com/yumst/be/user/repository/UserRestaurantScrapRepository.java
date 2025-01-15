package com.yumst.be.user.repository;

import com.yumst.be.user.domain.UserRestaurantScrap;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface UserRestaurantScrapRepository extends JpaRepository<UserRestaurantScrap, Long> {
    List<UserRestaurantScrap> findAllByUserId(String userId);
}
