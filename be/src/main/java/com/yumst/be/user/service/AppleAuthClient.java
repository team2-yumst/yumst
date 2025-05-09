package com.yumst.be.user.service;

import com.yumst.be.user.vo.response.ResponseApplePublicKey;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;

@FeignClient(name = "appleAuthClient", url = "${spring.security.oauth2.client.provider.apple.jwk-set-uri}")
public interface AppleAuthClient {
    @GetMapping
    ResponseApplePublicKey getApplePublicKey();
}
