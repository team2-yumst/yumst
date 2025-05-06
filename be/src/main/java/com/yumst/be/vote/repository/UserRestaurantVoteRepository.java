package com.yumst.be.vote.repository;

import com.yumst.be.vote.domain.UserRestaurantVote;
import org.springframework.data.jpa.repository.JpaRepository;

public interface UserRestaurantVoteRepository extends JpaRepository<UserRestaurantVote, Long> {
    Long countByRestaurantId(String restaurantId);
}
