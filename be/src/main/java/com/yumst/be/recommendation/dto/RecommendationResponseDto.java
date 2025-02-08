package com.yumst.be.recommendation.dto;


public class RecommendationResponseDto {
    private String restaurantId;
    private double similarity;

    public RecommendationResponseDto(String restaurantId, double similarity) {
        this.restaurantId = restaurantId;
        this.similarity = similarity;
    }

    public String getRestaurantId() {
        return restaurantId;
    }

    public double getSimilarity() {
        return similarity;
    }
}
