package com.yumst.be.user.exception;

import com.yumst.be.global.exception.ErrorCode;
import lombok.Getter;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;

@RequiredArgsConstructor
@Getter
public enum UserErrorCode implements ErrorCode {

    USER_NOT_FOUND(HttpStatus.NOT_FOUND, "사용자를 찾을 수 없습니다."),
    SOCIAL_LOGIN_FAILED(HttpStatus.BAD_REQUEST, "소셜로그인에 실패했습니다."),
    SOCIAL_REGISTER_FAILED(HttpStatus.BAD_REQUEST, "소셜회원가입에 실패했습니다."),
    ILLEGAL_REGISTRATION_ID(HttpStatus.BAD_REQUEST, "허용되지 않는 소셜로그인입니다."),
    INVALID_TOKEN(HttpStatus.UNAUTHORIZED, "유효하지 않은 토큰입니다."),
    INVALID_SIGNATURE(HttpStatus.UNAUTHORIZED, "유효하지 않은 서명입니다."),
    REFRESH_EXPIRED(HttpStatus.UNAUTHORIZED, "로그인이 만료되었습니다. 다시 로그인해 주세요.");

    private final HttpStatus httpStatus;
    private final String message;

}
