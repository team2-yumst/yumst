package com.yumst.be.redis.service;

import com.yumst.be.redis.entity.RefreshToken;
import com.yumst.be.redis.repository.RefreshTokenRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
@RequiredArgsConstructor
public class RefreshTokenRedisService {

    private final RefreshTokenRepository refreshTokenRepository;

    public void saveRefreshToken(String userId, String refreshToken, Long ttl) {

        RefreshToken token = RefreshToken.builder()
                .userId(userId)
                .refreshToken(refreshToken)
                .ttl(ttl)
                .build();

        refreshTokenRepository.save(token);
    }

    public Optional<RefreshToken> findRefreshToken(String userId) {
        return refreshTokenRepository.findById(userId);
    }

    public void deleteRefreshToken(String userId) {
        refreshTokenRepository.deleteById(userId);
    }

}
