package com.yumst.be.user.service;

import com.yumst.be.user.domain.UserEntity;
import com.yumst.be.user.dto.OAuth2UserInfo;
import com.yumst.be.user.dto.UserDto;
import com.yumst.be.user.repository.UserRepository;
import com.yumst.be.user.vo.request.RequestGoogleAccess;
import com.yumst.be.user.vo.response.ResponseGoogleAccess;
import lombok.RequiredArgsConstructor;
import org.modelmapper.ModelMapper;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.User;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.List;

@Service
@RequiredArgsConstructor
public class OAuthClient {

    private final RestTemplate restTemplate;

    @Value("${etc.google-profile-url}")
    private String profileUrl;

    private final UserRepository userRepository;

    private final ModelMapper modelMapper;

    public UserDto loadUserByAccess(String accessToken) {

        ResponseGoogleAccess body = requestToGoogle(accessToken);

        OAuth2UserInfo oAuth2UserInfo = OAuth2UserInfo.builder()
                .name(body.getName())
                .email(body.getEmail())
                .imageUrl(body.getPicture())
                .build();

        UserEntity userEntity = getOrSave(oAuth2UserInfo);
        return modelMapper.map(userEntity, UserDto.class);
    }

    public UsernamePasswordAuthenticationToken getAuthentication(String name) {
        List<GrantedAuthority> authorities = List.of(new SimpleGrantedAuthority("ROLE_USER"));
        User principal = new User(name, "", authorities);
        return new UsernamePasswordAuthenticationToken(principal, "", authorities);
    }

    private ResponseGoogleAccess requestToGoogle(String accessToken) {
        HttpHeaders headers = new HttpHeaders();
        headers.add(HttpHeaders.AUTHORIZATION, "Bearer " + accessToken);
        HttpEntity<RequestGoogleAccess> httpEntity = new HttpEntity<>(headers);

        return restTemplate.exchange(profileUrl, HttpMethod.GET, httpEntity, ResponseGoogleAccess.class)
                .getBody();
    }

    private UserEntity getOrSave(OAuth2UserInfo oAuth2UserInfo) {
        UserEntity userEntity = userRepository.findByEmail(oAuth2UserInfo.getEmail())
                .orElseGet(oAuth2UserInfo::toEntity);
        return userRepository.save(userEntity);
    }
}
