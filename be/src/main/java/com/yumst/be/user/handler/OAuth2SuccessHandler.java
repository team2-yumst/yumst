package com.yumst.be.user.handler;

import com.yumst.be.user.dto.PrincipalUserDetails;
import com.yumst.be.user.jwt.JwtProvider;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.Authentication;
import org.springframework.security.web.authentication.SimpleUrlAuthenticationSuccessHandler;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
@Slf4j
public class OAuth2SuccessHandler extends SimpleUrlAuthenticationSuccessHandler {

    private final JwtProvider jwtProvider;

    @Value("${etc.front-auth-success}")
    private String authSuccessUrl;


    @Override
    public void onAuthenticationSuccess(HttpServletRequest request, HttpServletResponse response, Authentication authentication){

        PrincipalUserDetails principal = (PrincipalUserDetails) authentication.getPrincipal();
        String userId = principal.getUserEntity().getUserId();

        String access = jwtProvider.generateAccessToken(authentication, userId);


        // TODO: 웹 사용시 경로 수정, 헤더->쿼리 파라미터로 수정
        response.setHeader("access", access);

//        response.sendRedirect(authSuccessUrl);
    }
}
