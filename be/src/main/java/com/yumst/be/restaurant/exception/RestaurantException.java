package com.yumst.be.restaurant.exception;

import com.yumst.be.global.exception.CustomException;

public class RestaurantException extends CustomException {

    public RestaurantException(RestaurantErrorCode errorCode) {
        super(errorCode);
    }
}
