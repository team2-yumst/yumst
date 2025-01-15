package com.yumst.be.user.handler;

import com.yumst.be.user.jwt.JwtProvider;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.Authentication;
import org.springframework.security.web.authentication.SimpleUrlAuthenticationSuccessHandler;
import org.springframework.stereotype.Component;

import java.io.IOException;

@Component
@RequiredArgsConstructor
@Slf4j
public class OAuth2SuccessHandler extends SimpleUrlAuthenticationSuccessHandler {

    private final JwtProvider jwtProvider;

    @Value("${etc.front-auth-success}")
    private String authSuccessUrl;


    @Override
    public void onAuthenticationSuccess(HttpServletRequest request, HttpServletResponse response, Authentication authentication) throws IOException, ServletException {

        log.info("OAuth2SuccessHandler onAuthenticationSuccess");

        String access = jwtProvider.generateAccessToken(authentication);
        String refresh = jwtProvider.generateRefreshToken(authentication);

        // TODO: 앱 개발후 경로 수정, 헤더->쿼리 파라미터로 수정
        response.setHeader("access", access);
        response.setHeader("refresh", refresh);

        response.sendRedirect(authSuccessUrl);
    }
}
