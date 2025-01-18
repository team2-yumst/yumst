package com.yumst.be.restaurant.controller;

import com.yumst.be.restaurant.service.RestaurantService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/restaurant/v1")
@RequiredArgsConstructor
public class RestaurantController {

    private final RestaurantService restaurantService;

    @GetMapping("/detail")
    public ResponseEntity<RestaurantResponseDTO> getRestaurantDetail(@RequestParam String restaurantId) {
        RestaurantResponseDTO restaurant = restaurantService.getRestaurantDetail(restaurantId);
        return ResponseEntity.ok(restaurant);
    }
}
