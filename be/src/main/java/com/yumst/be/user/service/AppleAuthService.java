package com.yumst.be.user.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.yumst.be.user.domain.UserEntity;
import com.yumst.be.user.dto.UserDto;
import com.yumst.be.user.jwt.JwtProvider;
import com.yumst.be.user.repository.UserRepository;
import com.yumst.be.user.vo.request.RequestAppleAuth;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

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

        UserEntity userEntity = UserEntity.createAppleUser(
                email,
                name,
                accountId
        );
        userRepository.save(userEntity);

        return UserDto.from(userEntity);
    }

    public String getAppleAccountId(String identityToken)
            throws JsonProcessingException, NoSuchAlgorithmException,
            InvalidKeySpecException {
        Map<String, String> headers = jwtProvider.parseHeaders(identityToken);

        // request to apple
        PublicKey publicKey = applePublicKeyGenerator.generatePublicKey(headers,
                                                                        appleAuthClient.getApplePublicKey());

        return jwtProvider.getTokenClaimsWithPubKey(identityToken, publicKey).getSubject();
    }

}