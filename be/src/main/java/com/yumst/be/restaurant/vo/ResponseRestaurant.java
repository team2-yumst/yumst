package com.yumst.be.restaurant.vo;

import lombok.Data;

@Data
public class ResponseRestaurant {

    private String name;
    private String category;

    private String latitude;
    private String longitude;

    private String thumbnailUrl;

    private String fullAddress;
    private String roadNameFullAddress;
}