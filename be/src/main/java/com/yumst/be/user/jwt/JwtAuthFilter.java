package com.yumst.be.user.jwt;

import com.yumst.be.user.exception.TokenException;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

import static com.yumst.be.user.exception.UserErrorCode.REFRESH_EXPIRED;

@Component
@Slf4j
@RequiredArgsConstructor
public class JwtAuthFilter extends OncePerRequestFilter {

    private final JwtProvider jwtProvider;

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain) throws ServletException, IOException {

        String accessToken = request.getHeader("access");
        String refreshToken = request.getHeader("refresh");

        if (accessToken == null || accessToken.isEmpty()) {
            filterChain.doFilter(request, response);
            return;
        }

        log.debug("Access token from request: {}", accessToken);
        log.debug("Refresh token from request: {}", refreshToken);

        validate(response, accessToken, refreshToken);

        setAuthentication(accessToken);
        filterChain.doFilter(request, response);
    }

    private void validate(HttpServletResponse response, String accessToken, String refreshToken) {
        // access 만료
        if (!jwtProvider.validateToken(accessToken)) {
            // refresh 정상
            if (jwtProvider.validateToken(refreshToken)) {
                log.debug("Access token is expired. Trying to reissue with refresh token.");
                // 재발급
                String newAccessToken = jwtProvider.reissueWithRefresh(refreshToken);
                response.setHeader("access", newAccessToken);
            }
            // refresh 만료
            log.debug("Refresh token is expired. Redirect to login page.");
            throw new TokenException(REFRESH_EXPIRED);
        }
    }

    private void setAuthentication(String accessToken) {
        Authentication authentication = jwtProvider.getAuthentication(accessToken);
        SecurityContextHolder.getContext().setAuthentication(authentication);
    }

}

