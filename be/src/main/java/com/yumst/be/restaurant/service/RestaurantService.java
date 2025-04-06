package com.yumst.be.restaurant.service;

import com.yumst.be.restaurant.domain.Restaurant;
import com.yumst.be.restaurant.domain.RestaurantNaverReviewFeatureCount;
import com.yumst.be.restaurant.domain.embed.NaverInformation;
import com.yumst.be.restaurant.domain.embed.OpenDataInformation;
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
        List<Restaurant> result = restaurantRepository.findTop10RestaurantsByCrawlCompleteTrue();
        return result.stream()
                .map(restaurant -> getResponseRestaurant(userId, restaurant))
                .collect(Collectors.toList());
    }

    public List<ResponseRestaurant> getResponseRestaurantList(List<String> restaurantIds, String userId) {
        return restaurantIds.stream()
                .map(restaurantId -> getResponseRestaurantByRestaurantId(userId, restaurantId))
                .collect(Collectors.toList());
    }

    private ResponseRestaurant getResponseRestaurantByRestaurantId(String userId, String restaurantId) {
        Restaurant restaurant = restaurantRepository.findByRestaurantId(restaurantId)
                .orElseThrow(() -> new RestaurantException(RESTAURANT_NOT_FOUND));
        return getResponseRestaurant(userId, restaurant);
    }

    private ResponseRestaurant getResponseRestaurant(String userId, Restaurant restaurant) {
        ResponseRestaurant responseRestaurant = new ResponseRestaurant();
        responseRestaurant.setRestaurantId(restaurant.getRestaurantId());
        addNaverInfoToResponse(responseRestaurant, restaurant.getNaverInformation());
        addOpenDataInfoToResponse(responseRestaurant, restaurant.getOpenDataInformation());
        addFeaturesToResponse(responseRestaurant, restaurant.getRestaurantId());
        addScrappedToResponse(responseRestaurant, restaurant.getRestaurantId(), userId);
        setLikeAndDislike(responseRestaurant, restaurant.getRestaurantId());
        return responseRestaurant;
    }

    private void addScrappedToResponse(ResponseRestaurant responseRestaurant,
                                       String restaurantId,
                                       String userId) {
        boolean result = userRestaurantScrapRepository.existsByUserIdAndRestaurantId(userId, restaurantId);
        responseRestaurant.setScrapped(result);
    }

    private void addFeaturesToResponse(ResponseRestaurant responseRestaurant, String restaurantId) {
        List<String> top2Features = naverReviewFeatureCountRepository.findTop2ByRestaurantIdOrderByReviewCountDesc(restaurantId)
                .stream()
                .map(c -> c.getNaverReviewFeature().getFeature())
                .toList();
        responseRestaurant.setTop2Features(top2Features);
    }

    private void addOpenDataInfoToResponse(ResponseRestaurant responseRestaurant, OpenDataInformation openDataInformation) {
        responseRestaurant.setFullAddress(openDataInformation.getFullAddress());
        responseRestaurant.setRoadNameFullAddress(openDataInformation.getRoadNameFullAddress());
        responseRestaurant.setPhoneNumber(openDataInformation.getContactNumber());
    }

    private void addNaverInfoToResponse(ResponseRestaurant responseRestaurant, NaverInformation naverInformation) {
        responseRestaurant.setName(naverInformation.getName());
        responseRestaurant.setCategory(naverInformation.getCategory());
        responseRestaurant.setLatitude(naverInformation.getLatitude());
        responseRestaurant.setLongitude(naverInformation.getLongitude());
        responseRestaurant.setThumbnailUrl(naverInformation.getThumbnailUrl());
        responseRestaurant.setTodayOpening(naverInformation.getTodayOperatingHours());
    }

    private void setLikeAndDislike(ResponseRestaurant responseRestaurant, String restaurantId) {
        Long likes = Long.valueOf(userRestaurantVoteRepository.countByRestaurantIdAndVoteType(restaurantId, VoteType.LIKE));
        Long dislikes = Long.valueOf(userRestaurantVoteRepository.countByRestaurantIdAndVoteType(restaurantId, VoteType.DISLIKE));
        responseRestaurant.setLikeCount(likes);
        responseRestaurant.setDislikeCount(dislikes);
    }

    public List<ResponseRestaurant> findNearbyRestaurants(String userId, Double latitude, Double longitude, Double radius, String sort, Pageable pageable) {
        Page<Object[]> results;

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
