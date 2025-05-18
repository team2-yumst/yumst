package com.yumst.be.recommendation.controller;

import com.yumst.be.recommendation.dto.request.RequestRecommend;
import com.yumst.be.recommendation.service.RecommendationService;
import com.yumst.be.restaurant.vo.ResponseRestaurant;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

import static org.springframework.http.HttpStatus.OK;

@RestController
@RequestMapping("api/recommendation/v2")
@RequiredArgsConstructor
public class RecommendationControllerV2 {

    private final RecommendationService recommendationService;

    @GetMapping("/ai")
    public ResponseEntity<List<ResponseRestaurant>> getRestaurant(@RequestHeader String userId,
                                                                   @ModelAttribute RequestRecommend requestRecommend) {

        List<ResponseRestaurant> result =
                recommendationService.getAiRecommendation(userId, requestRecommend);
        return ResponseEntity.status(OK).body(result);
    }

}
