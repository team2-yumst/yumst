package com.yumst.be.restaurant.service;

import com.yumst.be.recommendation.dto.response.RecommendedRestaurant;
import com.yumst.be.restaurant.domain.Restaurant;
import com.yumst.be.restaurant.exception.RestaurantException;
import com.yumst.be.restaurant.repository.NaverReviewFeatureCountRepository;
import com.yumst.be.restaurant.repository.RestaurantRepository;
import com.yumst.be.restaurant.vo.ResponseRestaurant;
import com.yumst.be.user.repository.UserRestaurantScrapRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

import static com.yumst.be.restaurant.exception.RestaurantErrorCode.RESTAURANT_NOT_FOUND;

@Service
@RequiredArgsConstructor
public class RestaurantService {

    private final RestaurantRepository restaurantRepository;
    private final NaverReviewFeatureCountRepository naverReviewFeatureCountRepository;
    private final UserRestaurantScrapRepository userRestaurantScrapRepository;

    public List<ResponseRestaurant> getRandomRestaurant(String userId) {

        List<Restaurant> result = restaurantRepository.findTop10RestaurantsByCrawlCompleteTrueOrderByNaverInformation();

        return result.stream().map(
                restaurant -> getResponseRestaurant(userId, restaurant))
                .collect(Collectors.toList());

    }

    public List<ResponseRestaurant> getResponseRestaurantFromRecommend(List<RecommendedRestaurant> results, String userId) {
        return results.stream()
                .map(recommendedRestaurant -> getResponseRestaurantWithDistanceByRestaurantId(
                        userId,
                        recommendedRestaurant.restaurantId(),
                        recommendedRestaurant.distance()))
                .toList();
    }


    public List<ResponseRestaurant> getResponseRestaurantList(List<String> restaurantIds, String userId) {
        return restaurantIds.stream()
                .map(restaurantId -> getResponseRestaurantByRestaurantId(userId, restaurantId))
                .toList();
    }

    private ResponseRestaurant getResponseRestaurantWithDistanceByRestaurantId(String userId, String restaurantId, double distance) {
        Restaurant restaurant = findRestaurantById(restaurantId);
        List<String> top2Features = findTop2Features(restaurant);
        boolean scrapped = userRestaurantScrapRepository.existsByUserIdAndRestaurantId(userId, restaurant.getRestaurantId());

        return ResponseRestaurant.from(
                restaurant,
                top2Features,
                scrapped,
                distance
        );
    }

    private ResponseRestaurant getResponseRestaurantByRestaurantId(String userId, String restaurantId) {
        Restaurant restaurant = findRestaurantById(restaurantId);
        return getResponseRestaurant(userId, restaurant);
    }

    private Restaurant findRestaurantById(String restaurantId) {
        return restaurantRepository.findByRestaurantId(restaurantId)
        .orElseThrow(() -> new RestaurantException(RESTAURANT_NOT_FOUND));
    }

    private ResponseRestaurant getResponseRestaurant(String userId, Restaurant restaurant) {

        List<String> top2Features = findTop2Features(restaurant);
        boolean scrapped = userRestaurantScrapRepository.existsByUserIdAndRestaurantId(userId, restaurant.getRestaurantId());

        return ResponseRestaurant.createWithNoDistance(
                restaurant,
                top2Features,
                scrapped
        );
    }

    private List<String> findTop2Features(Restaurant restaurant) {
        return naverReviewFeatureCountRepository
        .findTop2ByRestaurantIdOrderByReviewCountDesc(restaurant.getRestaurantId())
        .stream()
        .map(c -> c.getNaverReviewFeature().getFeature())
        .toList();
    }



}
