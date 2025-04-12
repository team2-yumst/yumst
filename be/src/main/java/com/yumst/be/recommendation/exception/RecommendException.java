package com.yumst.be.recommendation.exception;

import com.yumst.be.global.exception.CustomException;

public class RecommendException extends CustomException {
    public RecommendException(RecommendErrorCode errorCode) {
        super(errorCode);
    }

    public RecommendException(RecommendErrorCode errorCode, String message) {
        super(errorCode, message);
    }
}
