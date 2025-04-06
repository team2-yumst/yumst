package com.yumst.be.vote.dto;

import lombok.Data;

@Data
public class RestaurantRequest {
    private Double latitude;
    private Double longitude;
    private Double radius;
    private String sort;
    private Integer page;
} 