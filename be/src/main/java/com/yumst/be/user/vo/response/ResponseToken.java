package com.yumst.be.user.vo.response;

import lombok.Data;

@Data
public class ResponseToken {
    private String userId;

    public ResponseToken(String userId) {
        this.userId = userId;
    }
}
