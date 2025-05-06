package com.yumst.be.recommendation.controller;

import com.yumst.be.restaurant.service.RestaurantService;
import com.yumst.be.restaurant.vo.ResponseRestaurant;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("api/recommendation/v0")
@RequiredArgsConstructor
public class RecommendationControllerV0 {

    private final RestaurantService restaurantService;

    @GetMapping
    public ResponseEntity<List<ResponseRestaurant>> getRestaurant(
            @RequestHeader String userId
    ) {
        List<ResponseRestaurant> randomRestaurant = restaurantService.getRandomRestaurant(userId);
        return ResponseEntity.ok(randomRestaurant);
    }

}
