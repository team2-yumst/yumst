package com.yumst.be.vote.dto;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Data;
import java.util.List;

import static com.fasterxml.jackson.annotation.JsonInclude.Include.*;

@Data
@JsonInclude(NON_NULL)
public class ResponseRestaurant {
    private String restaurantId;
    private String name;
    private String category;
    private String latitude;
    private String longitude;
    private String thumbnailUrl;
    private String fullAddress;
    private String roadNameFullAddress;
    private String phoneNumber;
    private String todayOpening;
    private List<String> top2Features;
    private boolean isScrapped;
    private Long likeCount;
    private Long dislikeCount;
} 