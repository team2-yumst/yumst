package com.yumst.be.user.handler;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.web.authentication.SimpleUrlAuthenticationFailureHandler;
import org.springframework.stereotype.Component;

import java.io.IOException;

import static jakarta.servlet.http.HttpServletResponse.*;

@Component
@Slf4j
public class OAuth2FailureHandler extends SimpleUrlAuthenticationFailureHandler {

    @Override
    public void onAuthenticationFailure(HttpServletRequest request, HttpServletResponse response, AuthenticationException exception) throws IOException, ServletException {

        log.error("OAuth2FailureHandler onAuthenticationFailure");
        exception.printStackTrace();

        response.sendError(SC_BAD_REQUEST, "소셜 로그인에 실패했습니다.");
    }
}
