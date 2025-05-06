package com.yumst.be.recommendation.dto.response;

import java.util.List;

public record ResponseRecommend(
        long count,
        String next,
        String previous,
        List<RecommendedRestaurant> results
) {
}
