package com.yumst.be.restaurant.domain.embed;

import com.yumst.be.crawl.dto.CrawledNaverRestaurant;
import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Embeddable
@Data
@NoArgsConstructor
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

    @Builder
    public NaverInformation(String name, String category, String latitude, String longitude, String mondayHours, String tuesdayHours, String wednesdayHours, String thursdayHours, String fridayHours, String saturdayHours, String sundayHours, String phoneNumber, String thumbnailUrl, long visitorReviewCount, long blogReviewCount, double rating) {
        this.name = name;
        this.category = category;
        this.latitude = latitude;
        this.longitude = longitude;
        this.mondayHours = mondayHours;
        this.tuesdayHours = tuesdayHours;
        this.wednesdayHours = wednesdayHours;
        this.thursdayHours = thursdayHours;
        this.fridayHours = fridayHours;
        this.saturdayHours = saturdayHours;
        this.sundayHours = sundayHours;
        this.phoneNumber = phoneNumber;
        this.thumbnailUrl = thumbnailUrl;
        this.visitorReviewCount = visitorReviewCount;
        this.blogReviewCount = blogReviewCount;
        this.rating = rating;
    }

    public static NaverInformation from(CrawledNaverRestaurant crawledNaverRestaurant) {
        return NaverInformation.builder()
                .name(crawledNaverRestaurant.getName())
                .category(crawledNaverRestaurant.getCategory())
                .latitude(crawledNaverRestaurant.getLatitude())
                .longitude(crawledNaverRestaurant.getLongitude())
                .mondayHours(crawledNaverRestaurant.getMondayHours())
                .tuesdayHours(crawledNaverRestaurant.getTuesdayHours())
                .wednesdayHours(crawledNaverRestaurant.getWednesdayHours())
                .thursdayHours(crawledNaverRestaurant.getThursdayHours())
                .fridayHours(crawledNaverRestaurant.getFridayHours())
                .saturdayHours(crawledNaverRestaurant.getSaturdayHours())
                .sundayHours(crawledNaverRestaurant.getSundayHours())
                .phoneNumber(crawledNaverRestaurant.getPhoneNumber())
                .thumbnailUrl(crawledNaverRestaurant.getThumbnailUrl())
                .visitorReviewCount(Long.parseLong(crawledNaverRestaurant.getVisitorReviewCount().replace(",", "")))
                .blogReviewCount(Long.parseLong(crawledNaverRestaurant.getBlogReviewCount().replace(",", "")))
                .rating(Double.parseDouble(crawledNaverRestaurant.getRating()))
                .build();
    }
}
