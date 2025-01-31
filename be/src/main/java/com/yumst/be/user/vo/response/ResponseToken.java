package com.yumst.be.user.vo.response;

import lombok.Data;

@Data
public class ResponseToken {
    private String accessToken;
    private String refreshToken;

    public ResponseToken(String accessToken, String refreshToken) {
        this.accessToken = accessToken;
        this.refreshToken = refreshToken;
    }
}
