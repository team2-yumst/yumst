package com.yumst.be.recommendation.service;

import com.yumst.be.recommendation.dto.request.RequestRecommend;
import com.yumst.be.recommendation.dto.response.ResponseRecommend;
import com.yumst.be.recommendation.exception.RecommendException;
import com.yumst.be.restaurant.service.RestaurantService;
import com.yumst.be.restaurant.vo.ResponseRestaurant;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.UriComponentsBuilder;

import java.util.List;

import static com.yumst.be.recommendation.exception.RecommendErrorCode.RECOMMEND_SERVER_ERROR;

@Service
@RequiredArgsConstructor
@Slf4j
public class RecommendationService {

    private final RestaurantService restaurantService;
    private final RestTemplate restTemplate;

    @Value("${etc.recommend-url}")
    private String recommendationUrl;


    public List<ResponseRestaurant> getAiRecommendation(String userId, RequestRecommend requestRecommend) {
        ResponseEntity<ResponseRecommend> response =
                listFromRecommendServer(userId, requestRecommend, "ai", "v2");

        return restaurantService.getResponseRestaurantFromRecommend(response.getBody().results(), userId);
    }

    public List<ResponseRestaurant> getWalkRecommendationFromRecommendServer(String userId, RequestRecommend requestRecommend) {

        ResponseEntity<ResponseRecommend> response =
                listFromRecommendServer(userId, requestRecommend, "walk", "v1");

        return restaurantService.getResponseRestaurantFromRecommend(response.getBody().results(), userId);
    }



    public List<ResponseRestaurant> getCarRecommendationFromRecommendServer(String userId, RequestRecommend requestRecommend) {
        ResponseEntity<ResponseRecommend> response =
                listFromRecommendServer(userId, requestRecommend, "vehicle", "v1");

        return restaurantService.getResponseRestaurantFromRecommend(response.getBody().results(), userId);
    }

    private ResponseEntity<ResponseRecommend> listFromRecommendServer(
            String userId,
            RequestRecommend requestRecommend,
            String option,
            String version
    ) {
        HttpHeaders headers = new HttpHeaders();
        headers.set("userId", userId);
        headers.setAccept(List.of(MediaType.APPLICATION_JSON));

        HttpEntity<Void> entity = new HttpEntity<>(headers);

        String url = UriComponentsBuilder.fromUriString(recommendationUrl)
                .path("/api/recommendation/" + version + "/" + option)
                .queryParam("latitude", requestRecommend.latitude())
                .queryParam("longitude", requestRecommend.longitude())
                .queryParam("page", requestRecommend.page())
                .encode()
                .toUriString();

        try {
            return restTemplate.exchange(
                    url,
                    HttpMethod.GET,
                    entity,
                    ResponseRecommend.class
            );
        } catch (RestClientException e) {
            log.error("추천 서버 호출 실패", e);
            throw new RecommendException(
                    RECOMMEND_SERVER_ERROR,
                    "추천 서버가 응답하지 않았습니다: " + e.getMessage()
            );
        }
    }
}
