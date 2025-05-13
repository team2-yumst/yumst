package com.yumst.be.restaurant.vo;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.yumst.be.restaurant.domain.Restaurant;
import lombok.Builder;

import java.util.List;

import static com.fasterxml.jackson.annotation.JsonInclude.Include.NON_NULL;

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
        Double distance,
        String userVoteStatus
) {

    public static ResponseRestaurant from(Restaurant restaurant, List<String> top2Features, boolean isScrapped, double distance, String userVoteStatus) {
        return baseBuilder(restaurant, top2Features, isScrapped)
                .distance(distance)
                .userVoteStatus(userVoteStatus)
                .build();
    }

    public static ResponseRestaurant createWithNoDistance(Restaurant restaurant, List<String> top2Features, boolean isScrapped, String userVoteStatus) {
        return baseBuilder(restaurant, top2Features, isScrapped)
                .userVoteStatus(userVoteStatus)
                .build();
    }

    private static ResponseRestaurantBuilder baseBuilder(Restaurant restaurant, List<String> top2Features, boolean isScrapped) {
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
                .isScrapped(isScrapped);
    }

    public static ResponseRestaurant fromSearchResult(
            String restaurantId,
            String name,
            String category,
            String thumbnailUrl,
            Double distance,
            Boolean isScrapped,
            Long likeCount,
            Long dislikeCount,
            List<String> features,
            String userVoteStatus
    ) {
        return new ResponseRestaurant(
            restaurantId,
            name,
            category,
            null, // latitude
            null, // longitude
            thumbnailUrl,
            null, // fullAddress
            null, // roadNameFullAddress
            null, // phoneNumber
            null, // todayOpening
            features,
            isScrapped,
            likeCount,
            dislikeCount,
            distance,
            userVoteStatus
        );
    }

    @Builder
    public ResponseRestaurant(String restaurantId, String name, String category, String latitude, String longitude, String thumbnailUrl, String fullAddress, String roadNameFullAddress, String phoneNumber, String todayOpening, List<String> top2Features, boolean isScrapped, Long likeCount, Long dislikeCount, Double distance, String userVoteStatus) {
        this.restaurantId = restaurantId;
        this.name = name;
        this.category = category;
        this.latitude = latitude;
        this.longitude = longitude;
        this.thumbnailUrl = thumbnailUrl;
        this.fullAddress = fullAddress;
        this.roadNameFullAddress = roadNameFullAddress;
        this.phoneNumber = phoneNumber;
        this.todayOpening = todayOpening;
        this.top2Features = top2Features;
        this.isScrapped = isScrapped;
        this.likeCount = likeCount;
        this.dislikeCount = dislikeCount;
        this.distance = distance;
        this.userVoteStatus = userVoteStatus;
    }
}
