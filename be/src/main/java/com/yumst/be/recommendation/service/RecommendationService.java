package com.yumst.be.recommendation.service;

import com.yumst.be.recommendation.dto.request.RequestRecommend;
import com.yumst.be.recommendation.dto.response.ResponseRecommend;
import com.yumst.be.restaurant.service.RestaurantService;
import com.yumst.be.restaurant.vo.ResponseRestaurant;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.UriComponentsBuilder;

import java.util.List;

@Service
@RequiredArgsConstructor
public class RecommendationService {

    private final RestaurantService restaurantService;
    private final RestTemplate restTemplate;

    @Value("${etc.recommend-url}")
    private String recommendationUrl;


    public List<ResponseRestaurant> getWalkRecommendationFromRecommendServer(String userId, RequestRecommend requestRecommend) {

        ResponseEntity<ResponseRecommend> response =
                listFromRecommendServer(userId, requestRecommend, "walk");

        return restaurantService.getResponseRestaurantFromRecommend(response.getBody().results(), userId);
    }



    public List<ResponseRestaurant> getCarRecommendationFromRecommendServer(String userId, RequestRecommend requestRecommend) {
        ResponseEntity<ResponseRecommend> response =
                listFromRecommendServer(userId, requestRecommend, "vehicle");

        return restaurantService.getResponseRestaurantFromRecommend(response.getBody().results(), userId);
    }

    private ResponseEntity<ResponseRecommend> listFromRecommendServer(String userId, RequestRecommend requestRecommend, String walkOrCar) {
        HttpHeaders headers = new HttpHeaders();
        headers.add("userId", userId);
        HttpEntity<String> entity = new HttpEntity<>(headers);

        String url = UriComponentsBuilder.fromUriString(recommendationUrl)
                .path("/api/recommendation/v1/" + walkOrCar)
                .queryParam("latitude", requestRecommend.latitude())
                .queryParam("longitude", requestRecommend.longitude())
                .queryParam("page", requestRecommend.page())
                .encode()
                .toUriString();

        return restTemplate.exchange(
                url,
                HttpMethod.GET,
                entity,
                ResponseRecommend.class
        );
    }
}
