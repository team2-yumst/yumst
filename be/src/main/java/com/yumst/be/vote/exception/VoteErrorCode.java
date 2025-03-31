package com.yumst.be.vote.exception;

import com.yumst.be.global.exception.ErrorCode;
import lombok.Getter;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;

@RequiredArgsConstructor
@Getter
public enum VoteErrorCode implements ErrorCode {
    INVALID_VOTE_TYPE(HttpStatus.BAD_REQUEST, "잘못된 투표 타입입니다."),
    RESTAURANT_NOT_FOUND(HttpStatus.NOT_FOUND, "식당을 찾을 수 없습니다."),
    USER_NOT_FOUND(HttpStatus.NOT_FOUND, "사용자를 찾을 수 없습니다."),
    ALREADY_VOTED(HttpStatus.CONFLICT, "이미 투표한 식당입니다.");

    private final HttpStatus httpStatus;
    private final String message;
} 