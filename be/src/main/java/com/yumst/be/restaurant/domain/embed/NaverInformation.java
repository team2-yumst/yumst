package com.yumst.be.restaurant.domain.embed;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;
import lombok.Data;

@Embeddable
@Data
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

    @Column(length = 1024)
    private String thumbnailUrl;

    private long visitorReviewCount;
    private long blogReviewCount;

    private double rating;

    public String getTodayOperatingHours() {
        return switch (java.time.LocalDate.now().getDayOfWeek()) {
            case MONDAY -> mondayHours;
            case TUESDAY -> tuesdayHours;
            case WEDNESDAY -> wednesdayHours;
            case THURSDAY -> thursdayHours;
            case FRIDAY -> fridayHours;
            case SATURDAY -> saturdayHours;
            case SUNDAY -> sundayHours;
        };
    }
}
