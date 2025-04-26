package com.yumst.be.vote.controller;

import com.yumst.be.restaurant.vo.ResponseRestaurant;
import com.yumst.be.vote.dto.RestaurantRequest;
import com.yumst.be.vote.dto.VoteRequest;
import com.yumst.be.vote.dto.VoteResponse;
import com.yumst.be.vote.service.UserRestaurantVoteService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/vote/v1")
@RequiredArgsConstructor
public class UserRestaurantVoteController {
    private final UserRestaurantVoteService userRestaurantVoteService;

    @GetMapping("/restaurants")
    public ResponseEntity<List<ResponseRestaurant>> getVotableRestaurants(
            @RequestHeader("userId") String userId,
            @ModelAttribute RestaurantRequest restaurantRequest) {
        List<ResponseRestaurant> restaurants =
            userRestaurantVoteService.getVotableRestaurants(userId, restaurantRequest);
        return ResponseEntity.ok(restaurants);
    }

    @PatchMapping("/restaurants/{restaurantId}")
    public ResponseEntity<VoteResponse> vote(
            @RequestHeader("userId") String userId,
            @PathVariable String restaurantId,
            @Valid @RequestBody VoteRequest request) {
        return ResponseEntity.ok(userRestaurantVoteService.vote(userId, restaurantId, request.getVoteType()));
    }
} 