package com.yumst.be.user.controller;

import com.yumst.be.user.dto.UserDto;
import com.yumst.be.user.service.UserService;
import com.yumst.be.user.vo.RequestUser;
import com.yumst.be.user.vo.ResponseUser;
import lombok.RequiredArgsConstructor;
import org.modelmapper.ModelMapper;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import static org.springframework.http.HttpStatus.OK;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/user")
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

    @GetMapping("/v1/{userId}")
    public ResponseEntity<ResponseUser> getUser (@PathVariable String userId) {

        UserDto userDto = userService.getUser(userId);
        ResponseUser responseUser = modelMapper.map(userDto, ResponseUser.class);

        return ResponseEntity.status(OK).body(responseUser);
    }


    @DeleteMapping("/v1/{userId}")
    public ResponseEntity<ResponseUser> deleteUser (@PathVariable String userId) {

        UserDto userDto = userService.deleteUser(userId);
        ResponseUser responseUser = modelMapper.map(userDto, ResponseUser.class);

        return ResponseEntity.status(OK).body(responseUser);
    }

//    @PostMapping("/v1/scrap/{userId}/{restaurantId}")
//    public ResponseEntity<ResponseScrap> scrap (@PathVariable String userId, @PathVariable String restaurantId) {
//
//        userService.scrap(userId, restaurantId);
//
//        return ResponseEntity.status(OK).body();
//    }



}
