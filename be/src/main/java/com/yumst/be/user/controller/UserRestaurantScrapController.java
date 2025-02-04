package com.yumst.be.user.controller;

import com.yumst.be.user.service.UserRestaurantScrapService;
import com.yumst.be.user.vo.response.ResponseScrap;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import static org.springframework.http.HttpStatus.OK;

@RestController
@RequestMapping("/v1/scrap")
@RequiredArgsConstructor
public class UserRestaurantScrapController {

    private final UserRestaurantScrapService scrapService;

    @PostMapping("/{userId}/{restaurantId}")
    public ResponseEntity<ResponseScrap> scrap(
            @PathVariable String userId,
            @PathVariable String restaurantId) {

        ResponseScrap responseScrap = scrapService.toggleScrap(userId, restaurantId);

        return ResponseEntity.status(OK).body(responseScrap);
    }
}
