package com.yumst.be.vote.controller;

import com.yumst.be.vote.service.UserRestaurantVoteService;
import com.yumst.be.vote.dto.ResponseRestaurant;
import com.yumst.be.vote.dto.VoteRequest;
import com.yumst.be.vote.dto.VoteResponse;
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
            @RequestParam Double latitude,
            @RequestParam Double longitude,
            @RequestParam Double radius,
            @RequestParam(defaultValue = "distance") String sort,
            @RequestParam(defaultValue = "0") int page) {
        return ResponseEntity.ok(userRestaurantVoteService.getVotableRestaurants(userId, latitude, longitude, radius, sort, page));
    }

    @PostMapping("/{userId}/{restaurantId}")
    public ResponseEntity<VoteResponse> vote(
            @PathVariable String userId,
            @PathVariable String restaurantId,
            @RequestBody VoteRequest request) {
        return ResponseEntity.ok(userRestaurantVoteService.vote(userId, restaurantId, request.getVoteType()));
    }
} 