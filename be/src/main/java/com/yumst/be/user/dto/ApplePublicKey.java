package com.yumst.be.user.dto;

public record ApplePublicKey(
        String kty,
        String kid,
        String alg,
        String n,
        String e
) {
}
