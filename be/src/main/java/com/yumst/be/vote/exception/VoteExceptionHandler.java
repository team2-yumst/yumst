package com.yumst.be.vote.exception;

import com.yumst.be.global.exception.ErrorResponse;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@RestControllerAdvice
public class VoteExceptionHandler {

    @ExceptionHandler(VoteException.class)
    public ResponseEntity<ErrorResponse> handleVoteException(VoteException exception) {
        VoteErrorCode errorCode = exception.getErrorCode();
        ErrorResponse errorResponse = new ErrorResponse(errorCode);
        return ResponseEntity.status(errorCode.getHttpStatus()).body(errorResponse);
    }
} 