package com.yumst.be.user.exception;

import com.yumst.be.global.exception.CustomException;
import com.yumst.be.global.exception.ErrorCode;

public class TokenException extends CustomException {

    public TokenException(ErrorCode errorCode) {
        super(errorCode);
    }
}
