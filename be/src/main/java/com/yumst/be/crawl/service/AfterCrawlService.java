package com.yumst.be.crawl.service;

import com.yumst.be.crawl.dto.CrawledNaverRestaurant;
import com.yumst.be.restaurant.domain.NaverReviewFeature;
import com.yumst.be.restaurant.domain.Restaurant;
import com.yumst.be.restaurant.domain.RestaurantNaverReviewFeatureCount;
import com.yumst.be.restaurant.domain.embed.NaverInformation;
import com.yumst.be.restaurant.repository.NaverReviewFeatureCountRepository;
import com.yumst.be.restaurant.repository.NaverReviewFeatureRepository;
import com.yumst.be.restaurant.repository.RestaurantRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Slf4j
@RequiredArgsConstructor
public class AfterCrawlService {

    private final RestaurantRepository restaurantRepository;
    private final NaverReviewFeatureRepository naverReviewFeatureRepository;
    private final NaverReviewFeatureCountRepository naverReviewFeatureCountRepository;

    @Transactional
    public void updateRestaurant(String restaurantName, String address ,CrawledNaverRestaurant crawlResult) {

        Restaurant item = restaurantRepository.findFirstByOpenDataInformation_BusinessNameContainingAndOpenDataInformation_FullAddressContaining(
                restaurantName,
                address
        );
        updateFeature(item, crawlResult);

        NaverInformation naverInformation = NaverInformation.from(crawlResult);
        item.updateNaverCrawlData(naverInformation);

    }

    private void updateFeature(Restaurant item, CrawledNaverRestaurant crawlResult) {
        crawlResult.getReviewFeatureMap().forEach((key, value) -> {
            NaverReviewFeature naverReviewFeature = naverReviewFeatureRepository.findByFeature(key).
                    orElseGet(() -> naverReviewFeatureRepository.save(new NaverReviewFeature(key)));

            RestaurantNaverReviewFeatureCount restaurantNaverReviewFeatureCount = new RestaurantNaverReviewFeatureCount(
                    item.getRestaurantId(),
                    naverReviewFeature,
                    Long.valueOf(value)
            );
            naverReviewFeatureCountRepository.save(restaurantNaverReviewFeatureCount);
        });
    }

}
