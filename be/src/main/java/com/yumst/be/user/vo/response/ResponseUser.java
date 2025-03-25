package com.yumst.be.user.vo.response;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.yumst.be.restaurant.vo.ResponseRestaurant;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

import static com.fasterxml.jackson.annotation.JsonInclude.Include.NON_NULL;

@Data
@JsonInclude(NON_NULL)
@NoArgsConstructor
public class ResponseUser {

    private String userId;
    private String email;
    private String name;

    private String imageUrl;

    private boolean finishedSurvey;
    private boolean agreedPrivacyPolicy;
    private boolean agreedTermsOfService;
    private boolean agreedLocationTerms;

    private boolean isEnabled;

    private List<ResponseRestaurant> scrap;
}
