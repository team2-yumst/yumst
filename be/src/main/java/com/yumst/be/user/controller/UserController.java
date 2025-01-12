package com.yumst.be.user.controller;

import com.yumst.be.user.dto.UserDto;
import com.yumst.be.user.service.UserService;
import com.yumst.be.user.vo.RequestUser;
import com.yumst.be.user.vo.ResponseUser;
import lombok.RequiredArgsConstructor;
import org.modelmapper.ModelMapper;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

import static org.springframework.http.HttpStatus.OK;

@RestController("/api/user")
@RequiredArgsConstructor
public class UserController {

    private final ModelMapper modelMapper;
    private final UserService userService;

    @PostMapping("/v1")
    public ResponseEntity<ResponseUser> register (@RequestBody RequestUser user) {

        UserDto userDto = modelMapper.map(user, UserDto.class);

        UserDto registeredUser = userService.register(userDto);
        ResponseUser responseUser = modelMapper.map(registeredUser, ResponseUser.class);

        return ResponseEntity.status(OK).body(responseUser);

    }

}
