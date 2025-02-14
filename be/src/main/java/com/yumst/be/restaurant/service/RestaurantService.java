package com.yumst.be.restaurant.service;

import com.yumst.be.restaurant.domain.Restaurant;
import com.yumst.be.restaurant.repository.RestaurantRepository;
import com.yumst.be.restaurant.vo.ResponseRestaurant;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class RestaurantService {

    private final RestaurantRepository restaurantRepository;

    public List<ResponseRestaurant> getRandomRestaurant() {

        List<Restaurant> result = restaurantRepository.findTop10RestaurantsByCrawlCompleteTrue();

        return result.stream().map(restaurant -> {
            ResponseRestaurant responseRestaurant = new ResponseRestaurant();
            responseRestaurant.setName(restaurant.getNaverInformation().getName());
            responseRestaurant.setCategory(restaurant.getNaverInformation().getCategory());
            responseRestaurant.setLatitude(restaurant.getNaverInformation().getLatitude());
            responseRestaurant.setLongitude(restaurant.getNaverInformation().getLongitude());
            responseRestaurant.setThumbnailUrl(restaurant.getNaverInformation().getThumbnailUrl());
            responseRestaurant.setFullAddress(restaurant.getOpenDataInformation().getFullAddress());
            responseRestaurant.setRoadNameFullAddress(restaurant.getOpenDataInformation().getRoadNameFullAddress());
            return responseRestaurant;
        }).collect(Collectors.toList());

    }


}
