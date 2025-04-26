package com.yumst.be.recommendation.dto.response;

import com.fasterxml.jackson.annotation.JsonProperty;

public record RecommendedRestaurant(
        @JsonProperty("restaurant_id")
        String restaurantId,
        double distance,
        @JsonProperty("recommend_score")
        double recommendScore
) {
}
