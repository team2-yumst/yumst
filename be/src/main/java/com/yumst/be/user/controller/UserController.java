package com.yumst.be.user.controller;

import com.yumst.be.user.domain.UserEntity;
import com.yumst.be.user.dto.UserDto;
import com.yumst.be.user.jwt.JwtProvider;
import com.yumst.be.user.service.OAuthClient;
import com.yumst.be.user.service.UserService;
import com.yumst.be.user.vo.request.RequestToken;
import com.yumst.be.user.vo.response.ResponseToken;
import com.yumst.be.user.vo.response.ResponseUser;
import lombok.RequiredArgsConstructor;
import org.modelmapper.ModelMapper;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.web.bind.annotation.*;

import static org.springframework.http.HttpStatus.OK;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/user/v1")
public class UserController {

    private final ModelMapper modelMapper;
    private final UserService userService;
    private final OAuthClient oAuthClient;
    private final JwtProvider jwtProvider;

    @PostMapping("/login/google")
    public ResponseEntity<ResponseToken> googleLogin (@RequestBody RequestToken requestToken) {

        UserEntity user = oAuthClient.loadUserByAccess(requestToken.getAccessToken());
        UsernamePasswordAuthenticationToken authentication = oAuthClient.getAuthentication(user.getName());

        String accessToken = jwtProvider.generateAccessToken(authentication);
        String refreshToken = jwtProvider.generateRefreshToken(authentication);

        ResponseToken responseToken = new ResponseToken(accessToken, refreshToken);

        return ResponseEntity.status(OK).body(responseToken);
    }



    @GetMapping("/{userId}")
    public ResponseEntity<ResponseUser> getUser (@PathVariable String userId) {

        UserDto userDto = userService.getUser(userId);
        ResponseUser responseUser = modelMapper.map(userDto, ResponseUser.class);

        return ResponseEntity.status(OK).body(responseUser);
    }


    @DeleteMapping("/{userId}")
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
