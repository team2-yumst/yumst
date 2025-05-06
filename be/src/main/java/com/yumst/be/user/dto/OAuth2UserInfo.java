package com.yumst.be.user.dto;

import com.yumst.be.user.domain.UserEntity;
import com.yumst.be.user.exception.AuthException;
import lombok.Builder;
import lombok.Data;

import java.util.Map;

import static com.yumst.be.user.exception.UserErrorCode.ILLEGAL_REGISTRATION_ID;

@Data
@Builder
public class OAuth2UserInfo {

    private String name;
    private String email;
    private String imageUrl;

    public static OAuth2UserInfo of(String registrationId, Map<String, Object> attributes) {

        if (registrationId.equalsIgnoreCase("google")) {
            return ofGoogle(attributes);
        }

        if (registrationId.equalsIgnoreCase("apple")) {
            return ofApple(attributes);
        }

        throw new AuthException(ILLEGAL_REGISTRATION_ID);
    }

    private static OAuth2UserInfo ofGoogle(Map<String, Object> attributes) {
        return OAuth2UserInfo.builder()
                .name((String) attributes.get("name"))
                .email((String) attributes.get("email"))
                .imageUrl((String) attributes.get("picture"))
                .build();
    }

    private static OAuth2UserInfo ofApple(Map<String, Object> attributes) {
        // TODO: APPLE OAUTH 구현
        throw new AuthException(ILLEGAL_REGISTRATION_ID);
    }

    public UserEntity toEntity() {
        return UserEntity.builder()
                .name(name)
                .email(email)
                .imageUrl(imageUrl)
                .build();
    }
}
