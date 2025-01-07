package com.yumst.be.user.dto;

import lombok.Builder;
import lombok.Data;

@Data
public class OAuth2UserInfo {

    private String name;
    private String email;
    private String imageUrl;

    @Builder
    public OAuth2UserInfo(String name, String email, String imageUrl) {
        this.name = name;
        this.email = email;
        this.imageUrl = imageUrl;
    }

}
