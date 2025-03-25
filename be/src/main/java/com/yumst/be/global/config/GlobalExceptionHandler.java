package com.yumst.be.global.config;

import com.yumst.be.global.exception.CustomException;
import com.yumst.be.global.vo.ResponseError;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(CustomException.class)
    public ResponseEntity<ResponseError> handleCustomException(CustomException e) {

        ResponseError responseError = new ResponseError();
        responseError.setStatus(e.getErrorCode().getHttpStatus().value());
        responseError.setMessage(e.getMessage());
        return ResponseEntity.status(e.getErrorCode().getHttpStatus()).body(responseError);
    }

}