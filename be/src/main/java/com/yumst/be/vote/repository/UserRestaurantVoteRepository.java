package com.yumst.be.vote.repository;

import com.yumst.be.vote.domain.UserRestaurantVote;
import com.yumst.be.vote.dto.VoteType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;

public interface UserRestaurantVoteRepository extends JpaRepository<UserRestaurantVote, Long> {
    Optional<UserRestaurantVote> findByUserIdAndRestaurantId(String userId, String restaurantId);

    @Query("SELECT COUNT(v) FROM UserRestaurantVote v WHERE v.restaurantId = :restaurantId AND v.voteType = :voteType")
    Integer countByRestaurantIdAndVoteType(@Param("restaurantId") String restaurantId, @Param("voteType") VoteType voteType);
}
