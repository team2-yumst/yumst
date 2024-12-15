package com.yumst.be.restaurant.domain;

import jakarta.persistence.Embeddable;

@Embeddable
public class OpenDataInformation {

    private String name;
    private String imageUrl;
    private Integer rating;
    private Double priceRange; // 평균 가격대
    private Double latitude; // 위도
    private Double longitude; // 경도

}

