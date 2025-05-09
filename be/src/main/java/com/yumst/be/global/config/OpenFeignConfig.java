package com.yumst.be.global.config;

import org.springframework.cloud.openfeign.EnableFeignClients;
import org.springframework.context.annotation.Configuration;

@Configuration
@EnableFeignClients("com.yumst.be")
public class OpenFeignConfig {
}
