package com.yumst.be.user.vo.response;

import com.yumst.be.user.dto.ApplePublicKey;
import com.yumst.be.user.exception.AuthException;

import java.util.List;

import static com.yumst.be.user.exception.UserErrorCode.INVALID_TOKEN;

public record ResponseApplePublicKey(List<ApplePublicKey> keys) {

    public ApplePublicKey getMatchedKey(String kid, String alg){
        return keys.stream()
                .filter(key -> key.kid().equals(kid) && key.alg().equals(alg))
                .findAny()
                .orElseThrow(() -> new AuthException(INVALID_TOKEN));
    }
}
