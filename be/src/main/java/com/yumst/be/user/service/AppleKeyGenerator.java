package com.yumst.be.user.service;

import com.yumst.be.user.exception.AuthException;
import com.yumst.be.user.vo.response.ResponseAppleToken;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import lombok.RequiredArgsConstructor;
import org.bouncycastle.asn1.pkcs.PrivateKeyInfo;
import org.bouncycastle.openssl.PEMParser;
import org.bouncycastle.openssl.jcajce.JcaPEMKeyConverter;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.client.RestClient;

import java.io.IOException;
import java.io.Reader;
import java.io.StringReader;
import java.security.PrivateKey;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.Date;
import java.util.Objects;

import static com.yumst.be.user.exception.UserErrorCode.FAILED_REQUEST;

@Component
@RequiredArgsConstructor
public class AppleKeyGenerator {

    // APPLE_KEY_ID
    @Value("${etc.apple.key-id}")
    private String kid;
    // APPLE_TEAM_ID
    @Value("${etc.apple.team-id}")
    private String teamId;
    // APPLE_BUNDLE_ID
    @Value("${etc.apple.client-id}")
    private String appId;
    // APPLE_CLIENT_SECRET_FILE
    @Value("${etc.apple.client-secret}")
    private String privateKey;


    public String getAppleRefreshToken(String authorizationCode) {
        MultiValueMap<String, String> body = getCreateTokenBody(authorizationCode);

        RestClient restClient = RestClient.create();

        ResponseAppleToken appleTokenResponse = restClient.post()
                .uri("https://appleid.apple.com/auth/token")
                .contentType(MediaType.APPLICATION_FORM_URLENCODED)
                .body(body)
                .retrieve()
                .body(ResponseAppleToken.class);

        return Objects.requireNonNull(appleTokenResponse).getRefresh_token();
    }

    private MultiValueMap<String, String> getCreateTokenBody(String authorizationCode) {
        MultiValueMap<String, String> body = new LinkedMultiValueMap<>();
        body.add("code", authorizationCode);
        body.add("client_id", appId);
        body.add("client_secret", getClientSecret());
        body.add("grant_type", "authorization_code");
        return body;
    }

     // apple client secret 을 생성
    public String getClientSecret() {
        Date expirationDate = Date.from(LocalDateTime.now().plusDays(30).atZone(ZoneId.systemDefault()).toInstant());

        return Jwts.builder()
                .setHeaderParam("kid", kid)
                .setHeaderParam("alg", "ES256")
                .setIssuer(teamId)
                .setIssuedAt(new Date(System.currentTimeMillis()))
                .setExpiration(expirationDate)
                .setAudience("https://appleid.apple.com")
                .setSubject(appId)
                .signWith(getPrivateKey(), SignatureAlgorithm.ES256)
                .compact();
    }

    // apple private key
    private PrivateKey getPrivateKey() {
        try {
            Reader pemReader = new StringReader(privateKey.replace("\\n", "\n"));
            PEMParser pemParser = new PEMParser(pemReader);
            JcaPEMKeyConverter converter = new JcaPEMKeyConverter();
            PrivateKeyInfo object = (PrivateKeyInfo)pemParser.readObject();
            return converter.getPrivateKey(object);
        } catch (IOException e) {
            throw new AuthException(FAILED_REQUEST);
        }
    }


}
