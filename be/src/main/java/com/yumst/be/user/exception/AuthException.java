package com.yumst.be.user.exception;

import com.yumst.be.global.exception.CustomException;

public class AuthException extends CustomException {

    public AuthException(UserErrorCode errorCode) {
        super(errorCode);
    }

    public AuthException(UserErrorCode errorCode, String message) {
        super(errorCode, message);
    }
}
