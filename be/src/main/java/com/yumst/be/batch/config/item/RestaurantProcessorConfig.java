package com.yumst.be.batch.config.item;


import com.yumst.be.batch.dto.RestaurantCSVDto;
import com.yumst.be.crawl.dto.CrawledNaverRestaurant;
import com.yumst.be.crawl.service.SeleniumService;
import com.yumst.be.restaurant.domain.NaverReviewFeature;
import com.yumst.be.restaurant.domain.Restaurant;
import com.yumst.be.restaurant.domain.RestaurantNaverReviewFeatureCount;
import com.yumst.be.restaurant.domain.embed.NaverInformation;
import com.yumst.be.restaurant.domain.embed.OpenDataInformation;
import com.yumst.be.restaurant.repository.NaverReviewFeatureRepository;
import com.yumst.be.restaurant.repository.NaverReviewFeatureCountRepository;
import lombok.RequiredArgsConstructor;
import org.modelmapper.ModelMapper;
import org.springframework.batch.item.ItemProcessor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
@RequiredArgsConstructor
public class RestaurantProcessorConfig {

    private final ModelMapper modelMapper;
    private final SeleniumService seleniumService;

    private final NaverReviewFeatureRepository naverReviewFeatureRepository;
    private final NaverReviewFeatureCountRepository naverReviewFeatureCountRepository;

    @Bean
    public ItemProcessor<RestaurantCSVDto, Restaurant> csv2DBProcessor() {
        return new ItemProcessor<RestaurantCSVDto, Restaurant>() {
            @Override
            public Restaurant process(RestaurantCSVDto item) throws Exception {

                if (item.getBusinessStatusName().equals("폐업")) {
                    return null;
                }

                OpenDataInformation openDataInformation = modelMapper.map(item, OpenDataInformation.class);
                return Restaurant.builder()
                        .openDataInformation(openDataInformation)
                        .build();
            }
        };
    }


    @Bean
    public ItemProcessor<Restaurant, Restaurant> db2DBCrawlProcessor() {
        return new ItemProcessor<Restaurant, Restaurant>() {
            @Override
            public Restaurant process(Restaurant item) throws Exception {

                String businessName = item.getOpenDataInformation().getBusinessName();
                String fullAddress = item.getOpenDataInformation().getFullAddress();
                // 3번째 단어까지 자른 단어로 검색
                String searchAddress = fullAddress.split(" ")[0] + " " + fullAddress.split(" ")[1] + " " + fullAddress.split(" ")[2];
                CrawledNaverRestaurant crawlResult = seleniumService.crawl(businessName, searchAddress);

                updateFeature(item, crawlResult);

                NaverInformation naverInformation = NaverInformation.builder()
                        .name(crawlResult.getName())
                        .category(crawlResult.getCategory())
                        .latitude(crawlResult.getLatitude())
                        .longitude(crawlResult.getLongitude())
                        .mondayHours(crawlResult.getMondayHours())
                        .tuesdayHours(crawlResult.getTuesdayHours())
                        .wednesdayHours(crawlResult.getWednesdayHours())
                        .thursdayHours(crawlResult.getThursdayHours())
                        .fridayHours(crawlResult.getFridayHours())
                        .saturdayHours(crawlResult.getSaturdayHours())
                        .sundayHours(crawlResult.getSundayHours())
                        .phoneNumber(crawlResult.getPhoneNumber())
                        .thumbnailUrl(crawlResult.getThumbnailUrl())
                        .visitorReviewCount(Long.parseLong(crawlResult.getVisitorReviewCount().replace(",", "")))
                        .blogReviewCount(Long.parseLong(crawlResult.getBlogReviewCount().replace(",", "")))
                        .rating(Double.parseDouble(crawlResult.getRating()))
                        .build();

                item.updateNaverCrawlData(naverInformation);

                return item;
            }
        };
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
