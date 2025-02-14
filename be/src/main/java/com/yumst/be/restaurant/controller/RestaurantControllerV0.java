package com.yumst.be.restaurant.controller;

import com.yumst.be.restaurant.service.RestaurantService;
import com.yumst.be.restaurant.vo.ResponseRestaurant;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("api/restaurant/v0")
@RequiredArgsConstructor
public class RestaurantControllerV0 {

    private final RestaurantService restaurantService;

    @GetMapping
    public ResponseEntity<List<ResponseRestaurant>> getRestaurant() {

        List<ResponseRestaurant> randomRestaurant = restaurantService.getRandomRestaurant();
        return ResponseEntity.ok(randomRestaurant);
    }

}
