package com.yumst.be.user.jwt;

import com.yumst.be.redis.service.RefreshTokenRedisService;
import com.yumst.be.user.exception.TokenException;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.ExpiredJwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.MalformedJwtException;
import io.jsonwebtoken.security.SecurityException;
import jakarta.annotation.PostConstruct;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.User;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import javax.crypto.spec.SecretKeySpec;
import java.util.Date;
import java.util.List;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import static com.yumst.be.user.exception.UserErrorCode.INVALID_SIGNATURE;
import static com.yumst.be.user.exception.UserErrorCode.INVALID_TOKEN;
import static java.nio.charset.StandardCharsets.UTF_8;

@Component
@Slf4j
@RequiredArgsConstructor
public class JwtProvider {

    @Value("${jwt.secret}")
    private String secret;
    @Value("${jwt.expiration.access}")
    private Long ACCESS_TOKEN_EXPIRE_TIME;
    @Value("${jwt.expiration.refresh}")
    private Long REFRESH_TOKEN_EXPIRE_TIME;
    private SecretKey secretKey;

    private final RefreshTokenRedisService refreshTokenRedisService;


    @PostConstruct
    protected void initSecretKey() {
        this.secretKey = new SecretKeySpec(secret.getBytes(UTF_8),
                                           Jwts.SIG.HS512.key().build().getAlgorithm());
    }


    public String generateAccessToken(Authentication authentication, String userId) {

        String refreshToken = generateRefreshToken(authentication, userId);
        refreshTokenRedisService.saveRefreshToken(userId, refreshToken, REFRESH_TOKEN_EXPIRE_TIME);

        return generateToken(authentication, ACCESS_TOKEN_EXPIRE_TIME, "access", userId);
    }

    private String generateRefreshToken(Authentication authentication, String userId) {
        return generateToken(authentication, REFRESH_TOKEN_EXPIRE_TIME, "refresh", userId);
    }

    private String generateToken(Authentication authentication, Long expirationMs, String category, String userId) {

        String authorities = authentication.getAuthorities().stream()
                .map(GrantedAuthority::getAuthority)
                .collect(Collectors.joining());

        return Jwts.builder()
                .subject(userId)
                .claim("category", category)
                .claim("authorities", authorities)
                .issuedAt(new Date(System.currentTimeMillis()))
                .expiration(new Date(System.currentTimeMillis() + expirationMs))
                .signWith(secretKey)
                .compact();
    }

    // 만료되었을때만 false 반환
    public Boolean validateToken(String token) {
        try {
            Jwts.parser().verifyWith(secretKey).build()
                    .parseSignedClaims(token);
            return true;
        } catch (ExpiredJwtException e) {
            return false;
        } catch (MalformedJwtException e) {
            throw new TokenException(INVALID_TOKEN);
        } catch (SecurityException e) {
            throw new TokenException(INVALID_SIGNATURE);
        } catch (Exception e) {
            throw e;
        }
    }

    public Authentication getAuthentication(String token) {
        Claims claims = parseClaims(token);
        List<GrantedAuthority> authorities = Stream.of(claims.get("authorities", String.class).split(","))
                .map(SimpleGrantedAuthority::new)
                .collect(Collectors.toList());

        // security User
        User principal = new User(claims.getSubject(), "", authorities);
        return new UsernamePasswordAuthenticationToken(principal, token, authorities);
    }

    public String reissueWithRefresh(String refreshToken) {
        Authentication authentication = getAuthentication(refreshToken);
        String userId = getSubject(refreshToken);
        return generateAccessToken(authentication, userId);
    }

    private Claims parseClaims(String token) {
        try {
            return Jwts.parser().verifyWith(secretKey).build()
                    .parseSignedClaims(token)
                    .getPayload();
        } catch (ExpiredJwtException e) {
            return e.getClaims();
        }
    }

    // Subject - userId : userId 반환
    public String getSubject(String token) {
        return parseClaims(token).getSubject();
    }

}
