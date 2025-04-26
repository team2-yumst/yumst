package com.yumst.be.restaurant.service;

import com.yumst.be.recommendation.dto.response.RecommendedRestaurant;
import com.yumst.be.restaurant.domain.Restaurant;
import com.yumst.be.restaurant.exception.RestaurantException;
import com.yumst.be.restaurant.repository.NaverReviewFeatureCountRepository;
import com.yumst.be.restaurant.repository.RestaurantRepository;
import com.yumst.be.restaurant.vo.ResponseRestaurant;
import com.yumst.be.user.repository.UserRestaurantScrapRepository;
import com.yumst.be.vote.dto.VoteType;
import com.yumst.be.vote.repository.UserRestaurantVoteRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Page;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import static com.yumst.be.restaurant.exception.RestaurantErrorCode.RESTAURANT_NOT_FOUND;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class RestaurantService {

    private final RestaurantRepository restaurantRepository;
    private final NaverReviewFeatureCountRepository naverReviewFeatureCountRepository;
    private final UserRestaurantScrapRepository userRestaurantScrapRepository;
    private final UserRestaurantVoteRepository userRestaurantVoteRepository;

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


        switch (sort) {
            case "likes":
                results = restaurantRepository.findNearbyRestaurantsOrderByLikes(userId, latitude, longitude, radius, pageable);
                break;
            case "dislikes":
                results = restaurantRepository.findNearbyRestaurantsOrderByDislikes(userId, latitude, longitude, radius, pageable);
                break;
            case "distance":
            default:
                results = restaurantRepository.findNearbyRestaurantsOrderByDistance(userId, latitude, longitude, radius, pageable);
                break;
        }

        List<Object[]> content = results.getContent();

        if (content.isEmpty()) {
            return new ArrayList<>();
        }

        List<String> restaurantIds = content.stream()
                .map(result -> (String) result[0])
                .toList();

        List<RestaurantNaverReviewFeatureCount> allFeatures = naverReviewFeatureCountRepository.findTop2FeaturesForRestaurantIds(restaurantIds);

        Map<String, List<String>> featureMap = allFeatures.stream()
            .collect(Collectors.groupingBy(
                RestaurantNaverReviewFeatureCount::getRestaurantId,
                Collectors.mapping(rc -> rc.getNaverReviewFeature().getFeature(), Collectors.toList())
            ))
            .entrySet().stream()
            .collect(Collectors.toMap(
                Map.Entry::getKey,
                entry -> entry.getValue().stream().limit(2).toList()
            ));

        return content.stream()
                .map(result -> {
                    String restaurantId = (String) result[0];
                    String name = (String) result[1];
                    String category = (String) result[2];
                    String thumbnailUrl = (String) result[3];
                    Double dist = ((Number) result[4]).doubleValue();
                    Boolean isScrapped = (Boolean) result[5];
                    Long likeCount = ((Number) result[6]).longValue();
                    Long dislikeCount = ((Number) result[7]).longValue();

                    ResponseRestaurant response = new ResponseRestaurant();
                    response.setRestaurantId(restaurantId);
                    response.setName(name);
                    response.setCategory(category);
                    response.setThumbnailUrl(thumbnailUrl);
                    response.setDistance(dist);
                    response.setScrapped(isScrapped);
                    response.setLikeCount(likeCount);
                    response.setDislikeCount(dislikeCount);
                    response.setTop2Features(featureMap.getOrDefault(restaurantId, new ArrayList<>()));
                    
                    return response;
                })
                .toList();
    }
}
