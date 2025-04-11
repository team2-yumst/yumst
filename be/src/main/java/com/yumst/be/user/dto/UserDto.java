package com.yumst.be.user.dto;

import com.yumst.be.restaurant.vo.ResponseRestaurant;
import com.yumst.be.user.domain.UserEntity;
import lombok.Builder;
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


    public static UserDto from(UserEntity user) {
        return UserDto.builder()
                .userId(user.getUserId())
                .name(user.getName())
                .email(user.getEmail())
                .imageUrl(user.getImageUrl())
                .finishedSurvey(user.getUserTerms().isFinishedSurvey())
                .agreedPrivacyPolicy(user.getUserTerms().isAgreedPrivacyPolicy())
                .agreedTermsOfService(user.getUserTerms().isAgreedTermsOfService())
                .agreedLocationTerms(user.getUserTerms().isAgreedLocationTerms())
                .isEnabled(user.isEnabled())
                .build();
    }

    @Builder
    public UserDto(String userId, String name, String email, String imageUrl, boolean finishedSurvey, boolean agreedPrivacyPolicy, boolean agreedTermsOfService, boolean agreedLocationTerms, boolean isEnabled, List<ResponseRestaurant> scrap) {
        this.userId = userId;
        this.name = name;
        this.email = email;
        this.imageUrl = imageUrl;
        this.finishedSurvey = finishedSurvey;
        this.agreedPrivacyPolicy = agreedPrivacyPolicy;
        this.agreedTermsOfService = agreedTermsOfService;
        this.agreedLocationTerms = agreedLocationTerms;
        this.isEnabled = isEnabled;
        this.scrap = scrap;
    }

    public UserDto() {
    }
}
