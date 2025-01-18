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
    private String monday_hours;
    private String tuesday_hours;
    private String wednesday_hours;
    private String thursday_hours;
    private String friday_hours;
    private String saturday_hours;
    private String sunday_hours;
    private String phone_number;
    private String thumbnail_url;
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
    private String visitor_reviews;
    private String blog_reviews;
    private String rating;


}
