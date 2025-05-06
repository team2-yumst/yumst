package com.yumst.be.user.controller;

import com.yumst.be.user.dto.UserDto;
import com.yumst.be.user.jwt.JwtProvider;
import com.yumst.be.user.service.OAuthClient;
import com.yumst.be.user.service.UserService;
import com.yumst.be.user.vo.request.RequestFinalRegister;
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
        UserDto user = oAuthClient.loadUserByAccess(requestToken.getAccessToken());

        // yumst server jwt 발급
        String accessToken = getAccessToken(user);

        ResponseUser responseUser = modelMapper.map(user, ResponseUser.class);

        return ResponseEntity.status(OK)
                .header("access", accessToken)
                .body(responseUser);
    }


    @PostMapping("/login/guest")
    public ResponseEntity<ResponseUser> guestLogin() {
        UserDto userDto = userService.registerGuest();
        ResponseUser responseUser = modelMapper.map(userDto, ResponseUser.class);

        String accessToken = getAccessToken(userDto);

        return ResponseEntity.status(OK)
                .header("access", accessToken)
                .body(responseUser);
    }

    @PostMapping("/register/agree")
    public ResponseEntity<ResponseUser> agreeTerms(
            @RequestHeader String userId
    ) {
        userService.updateAgreeTerms(userId);
        return ResponseEntity.status(OK).body(null);
    }


    @PostMapping("/register/survey")
    public ResponseEntity<ResponseUser> registerFinalStepSurvey(
            @RequestHeader String userId,
            @RequestBody RequestFinalRegister requestFinalRegister
    ) {

        userService.updateSurveyInfo(userId, requestFinalRegister.getPreferences());
        return ResponseEntity.status(OK).body(null);
    }

    @PostMapping("/logout")
    public ResponseEntity<String> logout (@RequestHeader String userId) {

        userService.logout(userId);

        return ResponseEntity.status(OK).body("logout success");
    }

    @GetMapping()
    public ResponseEntity<ResponseUser> getUser (@RequestHeader String userId) {

        UserDto userDto = userService.findUserWithScrappedRestaurant(userId);
        ResponseUser responseUser = modelMapper.map(userDto, ResponseUser.class);

        return ResponseEntity.status(OK).body(responseUser);
    }


    @DeleteMapping()
    public ResponseEntity<ResponseUser> deleteUser (@RequestHeader String userId) {

        UserDto userDto = userService.deleteUser(userId);
        ResponseUser responseUser = modelMapper.map(userDto, ResponseUser.class);

        return ResponseEntity.status(OK).body(responseUser);
    }

    private String getAccessToken(UserDto user) {
        UsernamePasswordAuthenticationToken authentication = oAuthClient.getAuthentication(user.getEmail());
        return jwtProvider.generateAccessToken(authentication, user.getUserId());
    }

}
