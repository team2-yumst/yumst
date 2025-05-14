package com.yumst.be.vote.exception;

import lombok.Getter;

@Getter
public class VoteException extends RuntimeException {

    private final VoteErrorCode errorCode;

    public VoteException(VoteErrorCode errorCode) {
        super(errorCode.getMessage());
        this.errorCode = errorCode;
    }
} 