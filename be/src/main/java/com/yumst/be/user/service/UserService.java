package com.yumst.be.user.service;

import com.yumst.be.user.domain.UserEntity;
import com.yumst.be.user.dto.UserDto;
import com.yumst.be.user.exception.AuthException;
import com.yumst.be.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.modelmapper.ModelMapper;
import org.springframework.stereotype.Service;

import java.util.Optional;

import static com.yumst.be.user.exception.UserErrorCode.SOCIAL_REGISTER_FAILED;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;
    private final ModelMapper modelMapper;

    // OAuth 회원가입만 허용, 이미 추가된 회원을 대상으로 추가 정보를 물어보고 추가함
    public UserDto register(UserDto user) {

        Optional<UserEntity> byEmail = userRepository.findByEmail(user.getEmail());
        if (byEmail.isEmpty()) {
            throw new AuthException(SOCIAL_REGISTER_FAILED);
        }
        UserEntity findUser = byEmail.get();

        findUser.updateRegister(user.getGender(),
                                user.getAgeRange(),
                                user.getTendency());


        return modelMapper.map(findUser, UserDto.class);
    }

}
