package com.yumst.be.user.service;

import com.yumst.be.user.domain.UserEntity;
import com.yumst.be.user.dto.UserDto;
import com.yumst.be.user.exception.AuthException;
import com.yumst.be.user.repository.UserRepository;
import com.yumst.be.user.repository.UserRestaurantScrapRepository;
import lombok.RequiredArgsConstructor;
import org.modelmapper.ModelMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import static com.yumst.be.user.exception.UserErrorCode.SOCIAL_REGISTER_FAILED;
import static com.yumst.be.user.exception.UserErrorCode.USER_NOT_FOUND;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class UserService {

    private final UserRepository userRepository;
    private final ModelMapper modelMapper;
    private final UserRestaurantScrapRepository userRestaurantScrapRepository;

    // OAuth 회원가입만 허용, 이미 추가된 회원을 대상으로 추가 정보를 물어보고 추가함
    @Transactional
    public UserDto register(UserDto user) {

        UserEntity findUser = userRepository.findByEmail(user.getEmail())
                                            .orElseThrow(() -> new AuthException(SOCIAL_REGISTER_FAILED));

        UserEntity updated = findUser.updateRegister(user.getGender(),
                                                        user.getAgeRange(),
                                                        user.getTendency());

        return modelMapper.map(updated, UserDto.class);
    }

    public UserDto getUser(String userId) {
        UserEntity user = userRepository.findByUserId(userId)
                                        .orElseThrow(() -> new AuthException(USER_NOT_FOUND));
        return modelMapper.map(user, UserDto.class);
    }

    @Transactional
    public UserDto deleteUser(String userId) {

        UserEntity user = userRepository.deleteByUserId(userId)
                                        .orElseThrow(() -> new AuthException(USER_NOT_FOUND));

        return modelMapper.map(user, UserDto.class);
    }

}

