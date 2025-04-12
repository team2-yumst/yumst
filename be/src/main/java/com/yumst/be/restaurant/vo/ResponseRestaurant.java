package com.yumst.be.restaurant.vo;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.yumst.be.restaurant.domain.Restaurant;
import lombok.Builder;

import java.util.List;

import static com.fasterxml.jackson.annotation.JsonInclude.Include.NON_NULL;

@Builder
@JsonInclude(NON_NULL)
public record ResponseRestaurant(
        String restaurantId,
        String name,
        String category,
        String latitude,
        String longitude,
        String thumbnailUrl,
        String fullAddress,
        String roadNameFullAddress,
        String phoneNumber,
        String todayOpening,
        List<String> top2Features,
        boolean isScrapped,
        Long likeCount,
        Long dislikeCount,
        Double distance
) {

    public static ResponseRestaurant from(Restaurant restaurant, List<String> top2Features, boolean isScrapped, double distance) {
        return ResponseRestaurant.builder()
                .restaurantId(restaurant.getRestaurantId())
                .name(restaurant.getNaverInformation().getName())
                .category(restaurant.getNaverInformation().getCategory())
                .latitude(restaurant.getNaverInformation().getLatitude())
                .longitude(restaurant.getNaverInformation().getLongitude())
                .thumbnailUrl(restaurant.getNaverInformation().getThumbnailUrl())
                .fullAddress(restaurant.getOpenDataInformation().getFullAddress())
                .roadNameFullAddress(restaurant.getOpenDataInformation().getRoadNameFullAddress())
                .phoneNumber(restaurant.getOpenDataInformation().getContactNumber())
                .todayOpening(restaurant.getNaverInformation().getTodayOperatingHours())
                .top2Features(top2Features)
                .isScrapped(isScrapped)
                .distance(distance)
                .build();
    }

    public static ResponseRestaurant createWithNoDistance(Restaurant restaurant, List<String> top2Features, boolean isScrapped) {
        return ResponseRestaurant.builder()
                .restaurantId(restaurant.getRestaurantId())
                .name(restaurant.getNaverInformation().getName())
                .category(restaurant.getNaverInformation().getCategory())
                .latitude(restaurant.getNaverInformation().getLatitude())
                .longitude(restaurant.getNaverInformation().getLongitude())
                .thumbnailUrl(restaurant.getNaverInformation().getThumbnailUrl())
                .fullAddress(restaurant.getOpenDataInformation().getFullAddress())
                .roadNameFullAddress(restaurant.getOpenDataInformation().getRoadNameFullAddress())
                .phoneNumber(restaurant.getOpenDataInformation().getContactNumber())
                .todayOpening(restaurant.getNaverInformation().getTodayOperatingHours())
                .top2Features(top2Features)
                .isScrapped(isScrapped)
                .build();
    }

}
