package com.yumst.be.crawl.dto;

import lombok.Builder;
import lombok.Data;

import java.util.Map;

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

    private Map<String, String> reviewFeatureMap;

    private String visitorReviewCount;
    private String blogReviewCount;
    private String rating;


}
