package com.yumst.be.user.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.yumst.be.user.domain.UserEntity;
import com.yumst.be.user.dto.UserDto;
import com.yumst.be.user.jwt.JwtProvider;
import com.yumst.be.user.repository.UserRepository;
import com.yumst.be.user.vo.request.RequestAppleAuth;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.client.RestClient;

import java.security.NoSuchAlgorithmException;
import java.security.PublicKey;
import java.security.spec.InvalidKeySpecException;
import java.util.Map;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class AppleAuthService {
    private final AppleAuthClient appleAuthClient;
    private final ApplePublicKeyGenerator applePublicKeyGenerator;
    private final UserRepository userRepository;
    private final JwtProvider jwtProvider;
    private final AppleKeyGenerator appleKeyGenerator;

    @Value("${etc.apple.client-id}")
    private String clientId;


    public UserDto loadUser(RequestAppleAuth appleAuth)
            throws NoSuchAlgorithmException, InvalidKeySpecException,
            JsonProcessingException {
        String accountId = getAppleAccountId(appleAuth.idToken());

        Optional<UserEntity> user = userRepository.findByUserId(accountId);
        if (user.isPresent()) {
            return UserDto.from(user.get());
        }

        String name = appleAuth.user().name().lastName() + appleAuth.user().name().firstName();
        String email = appleAuth.user().email();
        String appleRefreshToken = appleKeyGenerator.getAppleRefreshToken(appleAuth.authorizationCode());

        UserEntity userEntity = UserEntity.createAppleUser(
                email,
                name,
                accountId,
                appleRefreshToken
        );
        userRepository.save(userEntity);

        return UserDto.from(userEntity);
    }

    public void revokeToken(String refreshToken) {
        MultiValueMap<String, String> body = getRevokeTokenBody(refreshToken);

        RestClient restClient = RestClient.create();

        restClient.post()
                .uri("https://appleid.apple.com/auth/revoke")
                .contentType(MediaType.APPLICATION_FORM_URLENCODED)
                .body(body)
                .retrieve()
                .toBodilessEntity();
    }

    private MultiValueMap<String, String> getRevokeTokenBody(String refreshToken) {
        MultiValueMap<String, String> body = new LinkedMultiValueMap<>();
        body.add("client_id", clientId);
        body.add("token", refreshToken);
        body.add("client_secret", appleKeyGenerator.getClientSecret());
        body.add("token_type_hint", "refresh_token");
        return body;
    }

    private String getAppleAccountId(String identityToken)
            throws JsonProcessingException, NoSuchAlgorithmException,
            InvalidKeySpecException {
        Map<String, String> headers = jwtProvider.parseHeaders(identityToken);

        // request to apple
        PublicKey publicKey = applePublicKeyGenerator.generatePublicKey(headers,
                                                                        appleAuthClient.getApplePublicKey());

        return jwtProvider.getTokenClaimsWithPubKey(identityToken, publicKey).getSubject();
    }
}