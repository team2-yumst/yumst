package com.yumst.be.recommendation.controller;


import com.yumst.be.recommendation.service.RecommendationService;
import com.yumst.be.restaurant.domain.Restaurant;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/recommend/v1")
@RequiredArgsConstructor
public class RecommendationController {

    private final RecommendationService recommendationService;

    @GetMapping("/{userId}")
    public ResponseEntity<List<Restaurant>> getNearbyRestaurants(
            @PathVariable String userId,
            @RequestParam double latitude,
            @RequestParam double longitude
    ) {
        List<Restaurant> recommendations = recommendationService.getNearbyRestaurants(userId, latitude, longitude);
        return ResponseEntity.ok(recommendations);
    }
}
