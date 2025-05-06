package com.yumst.be.restaurant.exception;

import com.yumst.be.global.exception.ErrorCode;
import lombok.Getter;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;

@RequiredArgsConstructor
@Getter
public enum RestaurantErrorCode implements ErrorCode {

    RESTAURANT_NOT_FOUND(HttpStatus.NOT_FOUND, "식당을 찾을 수 없습니다.");

    private final HttpStatus httpStatus;
    private final String message;

}
