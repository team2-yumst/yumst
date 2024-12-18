package com.yumst.be.user.exception;

import com.yumst.be.global.exception.ErrorCode;
import lombok.Getter;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;

@RequiredArgsConstructor
@Getter
public enum AuthExceptionCode implements ErrorCode {

    ILLEGAL_REGISTRATION_ID(HttpStatus.BAD_REQUEST, "허용되지 않는 소셜로그인입니다.");

    private final HttpStatus httpStatus;
    private final String message;

}
