package com.yumst.be.user.dto;

import com.yumst.be.restaurant.vo.ResponseRestaurant;
import lombok.Data;

import java.util.List;

@Data
public class UserDto {
    private String userId;
    private String name;
    private String email;

    private String imageUrl;

    private boolean finishedSurvey;
    private boolean agreedPrivacyPolicy;
    private boolean agreedTermsOfService;
    private boolean agreedLocationTerms;

    private boolean isEnabled;

    private List<ResponseRestaurant> scrap;
}
