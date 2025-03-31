package com.yumst.be.vote.exception;

import com.yumst.be.global.exception.CustomException;

public class VoteException extends CustomException {
    public VoteException(VoteErrorCode errorCode) {
        super(errorCode);
    }
} 