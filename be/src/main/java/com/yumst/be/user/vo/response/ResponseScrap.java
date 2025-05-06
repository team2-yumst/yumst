package com.yumst.be.user.vo.response;

import lombok.Data;

@Data
public class ResponseScrap {

    private String userId;
    private String restaurantId;
    private boolean scrapped;

    public ResponseScrap(String userId, String restaurantId, boolean scrapped) {
        this.userId = userId;
        this.restaurantId = restaurantId;
        this.scrapped = scrapped;
    }
}
