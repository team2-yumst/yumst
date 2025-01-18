package com.yumst.be.crawl.dto;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class CrawledNaverRestaurant {

    private String name;
    private String category;
    private String latitude;
    private String longitude;
    private String mondayHours;
    private String tuesdayHours;
    private String wednesdayHours;
    private String thursdayHours;
    private String fridayHours;
    private String saturdayHours;
    private String sundayHours;
    private String phoneNumber;
    private String thumbnailUrl;
    private String feature1;
    private String feature2;
    private String feature3;
    private String feature4;
    private String feature5;
    private String feature6;
    private String feature7;
    private String feature8;
    private String feature9;
    private String feature10;
    private String visitorReviewCount;
    private String blogReviewCount;
    private String rating;


}
