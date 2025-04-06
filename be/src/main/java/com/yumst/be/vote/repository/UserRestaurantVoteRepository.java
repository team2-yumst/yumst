package com.yumst.be.vote.repository;

import com.yumst.be.vote.domain.UserRestaurantVote;
import com.yumst.be.vote.dto.VoteType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface UserRestaurantVoteRepository extends JpaRepository<UserRestaurantVote, Long> {
    @Query("SELECT v FROM UserRestaurantVote v WHERE v.userId = :userId AND v.restaurantId = :restaurantId")
    Optional<UserRestaurantVote> findByUserIdAndRestaurantId(@Param("userId") String userId, @Param("restaurantId") String restaurantId);

    @Query("SELECT COUNT(v) FROM UserRestaurantVote v WHERE v.restaurantId = :restaurantId AND v.voteType = :voteType")
    Integer countByRestaurantIdAndVoteType(@Param("restaurantId") String restaurantId, @Param("voteType") VoteType voteType);

    @Query("""
        SELECT v.restaurantId, v.voteType, COUNT(v) as count 
        FROM UserRestaurantVote v 
        WHERE v.restaurantId IN :restaurantIds 
        GROUP BY v.restaurantId, v.voteType
    """)
    List<Object[]> countVotesByRestaurantIds(@Param("restaurantIds") List<String> restaurantIds);
}
