package com.yumst.be.recommendation.dto.request;

import jakarta.validation.constraints.NotNull;

public record RequestRecommend(
        @NotNull(message = "위도는 필수입니다.")
        double latitude,
        @NotNull(message = "경도는 필수입니다.")
        double longitude,
        @NotNull(message = "페이지는 필수입니다.")
        int page
) {

}
