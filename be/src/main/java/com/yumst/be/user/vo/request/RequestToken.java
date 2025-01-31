package com.yumst.be.user.vo.request;

import lombok.Data;

@Data
public class RequestToken {
    private String accessToken;
    private String idToken;
}
