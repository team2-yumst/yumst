package com.yumst.be.user.controller;

import com.yumst.be.user.service.UserRestaurantScrapService;
import com.yumst.be.user.vo.response.ResponseScrap;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import static org.springframework.http.HttpStatus.OK;

@RestController
@RequiredArgsConstructor
@RequestMapping("api/user/v1")
public class UserRestaurantScrapController {

    private final UserRestaurantScrapService scrapService;

    @PostMapping("/scrap/{restaurantId}")
    public ResponseEntity<ResponseScrap> scrap(
            @RequestHeader String userId,
            @PathVariable String restaurantId) {

        ResponseScrap responseScrap = scrapService.toggleScrap(userId, restaurantId);

        return ResponseEntity.status(OK).body(responseScrap);
    }
}
