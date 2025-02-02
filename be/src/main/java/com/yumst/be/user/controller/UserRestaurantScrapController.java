package com.yumst.be.user.controller;

import com.yumst.be.user.domain.UserRestaurantScrap;
import com.yumst.be.user.service.UserRestaurantScrapService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import static org.springframework.http.HttpStatus.OK;

@RestController
@RequestMapping("/v1/scrap")
@RequiredArgsConstructor
public class UserRestaurantScrapController {

    private final UserRestaurantScrapService scrapService;

    @PostMapping("/{userId}/{restaurantId}")
    public ResponseEntity<UserRestaurantScrap> scrap(
            @PathVariable String userId,
            @PathVariable String restaurantId) {

        UserRestaurantScrap result = scrapService.toggleScrap(userId, restaurantId);
        return ResponseEntity.status(OK).body(result);
    }
}
