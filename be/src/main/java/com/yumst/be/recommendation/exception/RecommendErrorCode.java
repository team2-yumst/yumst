package com.yumst.be.recommendation.exception;

import com.yumst.be.global.exception.ErrorCode;
import lombok.Getter;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;

import static org.springframework.http.HttpStatus.*;

@RequiredArgsConstructor
@Getter
public enum RecommendErrorCode implements ErrorCode {

    RECOMMEND_SERVER_ERROR(INTERNAL_SERVER_ERROR, "추천 서버와의 통신에 실패했습니다.");

    private final HttpStatus httpStatus;
    private final String message;
}
