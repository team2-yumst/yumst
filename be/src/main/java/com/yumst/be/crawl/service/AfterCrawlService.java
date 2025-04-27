package com.yumst.be.crawl.service;

import com.yumst.be.crawl.dto.CrawledNaverRestaurant;
import com.yumst.be.restaurant.repository.NaverReviewFeatureCountRepository;
import com.yumst.be.restaurant.repository.NaverReviewFeatureRepository;
import com.yumst.be.restaurant.repository.RestaurantRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

@Service
@Slf4j
@RequiredArgsConstructor
public class AfterCrawlService {

    private final RestaurantRepository restaurantRepository;
    private final NaverReviewFeatureRepository naverReviewFeatureRepository;
    private final NaverReviewFeatureCountRepository naverReviewFeatureCountRepository;


    public void updateRestaurant(CrawledNaverRestaurant crawled) {

    }

}
