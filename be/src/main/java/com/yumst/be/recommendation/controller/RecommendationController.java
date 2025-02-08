package com.yumst.be.recommendation.controller;


import com.yumst.be.recommendation.service.RecommendationService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/recommend")
@RequiredArgsConstructor
public class RecommendationController {

    private final RecommendationService recommendationService;

    @GetMapping("/v1/{userId}")
    public ResponseEntity<List<UUID>> recommendRestaurants(@PathVariable UUID userId) {
        List<UUID> recommendations = recommendationService.getRecommendedRestaurants(userId);
        return ResponseEntity.ok(recommendations);
    }
}

