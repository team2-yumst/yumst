package com.yumst.be.user.service;

import com.yumst.be.user.domain.UserEntity;
import com.yumst.be.user.dto.PrincipalUserDetails;
import com.yumst.be.user.exception.AuthException;
import com.yumst.be.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.stereotype.Service;

import static com.yumst.be.user.exception.UserErrorCode.USER_NOT_FOUND;

@Service
@RequiredArgsConstructor
public class CustomUsersDetailsService implements UserDetailsService {

    private final UserRepository userRepository;

    @Override
    public UserDetails loadUserByUsername(String username) {
        UserEntity userEntity = userRepository.findByEmail(username)
                .orElseThrow(() -> new AuthException(USER_NOT_FOUND));

        return new PrincipalUserDetails(userEntity);
    }
}