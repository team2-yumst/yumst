package com.yumst.be.restaurant.domain.embed;

import jakarta.persistence.Embeddable;

@Embeddable
public class NaverInformation {

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

    private long visitorReviewCount;
    private long blogReviewCount;

    private double rating;

}
