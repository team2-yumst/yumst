package com.yumst.be.user.vo.response;

import lombok.Getter;

@Getter
public class ResponseAppleToken {
    private String access_token;
    private String expires_in;
    private String id_token;
    private String refresh_token;
    private String token_type;
    private String error;
}