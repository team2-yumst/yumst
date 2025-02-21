package com.yumst.be.restaurant.service;

import com.yumst.be.restaurant.domain.Restaurant;
import com.yumst.be.restaurant.domain.embed.NaverInformation;
import com.yumst.be.restaurant.domain.embed.OpenDataInformation;
import com.yumst.be.restaurant.repository.NaverReviewFeatureCountRepository;
import com.yumst.be.restaurant.repository.RestaurantRepository;
import com.yumst.be.restaurant.vo.ResponseRestaurant;
import com.yumst.be.user.repository.UserRestaurantScrapRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class RestaurantService {

    private final RestaurantRepository restaurantRepository;
    private final NaverReviewFeatureCountRepository naverReviewFeatureCountRepository;
    private final UserRestaurantScrapRepository userRestaurantScrapRepository;

    public List<ResponseRestaurant> getRandomRestaurant(String userId) {

        List<Restaurant> result = restaurantRepository.findTop10RestaurantsByCrawlCompleteTrue();

        return result.stream().map(restaurant -> {
            ResponseRestaurant responseRestaurant = new ResponseRestaurant();

            responseRestaurant.setRestaurantId(restaurant.getRestaurantId());
            setNaverInfo(responseRestaurant, restaurant.getNaverInformation());
            setOpenDataInfo(responseRestaurant, restaurant.getOpenDataInformation());
            setFeatures(responseRestaurant, restaurant.getRestaurantId());
            setScrapped(responseRestaurant, restaurant.getRestaurantId(), userId);
            // TODO: V2 투표기능 개발후 추가
//            setLikeAndDislike(responseRestaurant, restaurant.getRestaurantId());

            return responseRestaurant;
        }).collect(Collectors.toList());

    }

    private void setScrapped(ResponseRestaurant responseRestaurant,
                             String restaurantId,
                             String userId) {
        boolean result = userRestaurantScrapRepository.existsByUserIdAndRestaurantId(userId, restaurantId);
        responseRestaurant.setScrapped(result);
    }

    private void setFeatures(ResponseRestaurant responseRestaurant, String restaurantId) {
        List<String> top2Features = naverReviewFeatureCountRepository.findTop2ByRestaurantIdOrderByReviewCountDesc(restaurantId)
                .stream()
                .map(c -> c.getNaverReviewFeature().getFeature())
                .toList();
        responseRestaurant.setTop2Features(top2Features);
    }

    private void setOpenDataInfo(ResponseRestaurant responseRestaurant, OpenDataInformation openDataInformation) {
        responseRestaurant.setFullAddress(openDataInformation.getFullAddress());
        responseRestaurant.setRoadNameFullAddress(openDataInformation.getRoadNameFullAddress());
        responseRestaurant.setPhoneNumber(openDataInformation.getContactNumber());
    }

    private void setNaverInfo(ResponseRestaurant responseRestaurant, NaverInformation naverInformation) {
        responseRestaurant.setName(naverInformation.getName());
        responseRestaurant.setCategory(naverInformation.getCategory());
        responseRestaurant.setLatitude(naverInformation.getLatitude());
        responseRestaurant.setLongitude(naverInformation.getLongitude());
        responseRestaurant.setThumbnailUrl(naverInformation.getThumbnailUrl());
        responseRestaurant.setTodayOpening(naverInformation.getTodayOperatingHours());
    }




}
