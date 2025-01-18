package com.yumst.be.restaurant.service;

import com.yumst.be.restaurant.domain.Restaurant;
import com.yumst.be.restaurant.repository.RestaurantRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class RestaurantService {

    private final RestaurantRepository restaurantRepository;

    public RestaurantResponseDTO getRestaurantDetail(String restaurantId) {
        Restaurant restaurant = restaurantRepository.findByRestaurantId(restaurantId)
                .orElseThrow(() -> new IllegalArgumentException("Restaurant not found with ID: " + restaurantId));

        return RestaurantResponseDTO.fromEntity(restaurant);
    }
}
