package com.yumst.be.user.controller;

import com.yumst.be.user.domain.UserEntity;
import com.yumst.be.user.dto.UserDto;
import com.yumst.be.user.jwt.JwtProvider;
import com.yumst.be.user.service.OAuthClient;
import com.yumst.be.user.service.UserService;
import com.yumst.be.user.vo.request.RequestToken;
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
    public ResponseEntity<ResponseUser> googleLogin (@RequestBody RequestToken requestToken) {

        // google(resource server)로 요청
        // yumst db에 존재하면 반환, 없으면 추가
        UserEntity user = oAuthClient.loadUserByAccess(requestToken.getAccessToken());

        // yumst server jwt 발급
        UsernamePasswordAuthenticationToken authentication = oAuthClient.getAuthentication(user.getEmail());
        String accessToken = jwtProvider.generateAccessToken(authentication, user.getUserId());

        ResponseUser responseUser = ResponseUser.builder()
                .userId(user.getUserId())
                .email(user.getEmail())
                .name(user.getName())
                .build();

        return ResponseEntity.status(OK)
                .header("access", accessToken)
                .body(responseUser);
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
