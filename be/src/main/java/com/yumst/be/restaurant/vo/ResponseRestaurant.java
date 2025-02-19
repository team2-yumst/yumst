package com.yumst.be.restaurant.vo;

import lombok.Data;

import java.util.List;

@Data
public class ResponseRestaurant {

    private String restaurantId;

    private String name;
    private String category;

    private String latitude;
    private String longitude;

    private String thumbnailUrl;

    private String fullAddress;
    private String roadNameFullAddress;

    private String phoneNumber;

    private String todayOpening;
    private List<String> top2Features;

    private boolean isScrapped;

    private Long likeCount;
    private Long dislikeCount;
}