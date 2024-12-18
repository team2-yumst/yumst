package com.yumst.be.user.exception;

import com.yumst.be.global.exception.CustomException;

public class AuthException extends CustomException {

    public AuthException(AuthExceptionCode errorCode) {
        super(errorCode);
    }
}
