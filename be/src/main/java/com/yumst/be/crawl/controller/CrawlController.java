package com.yumst.be.crawl.controller;

import com.yumst.be.crawl.dto.CrawledNaverRestaurant;
import com.yumst.be.crawl.service.AfterCrawlService;
import com.yumst.be.crawl.service.SeleniumService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
public class CrawlController {

    private final SeleniumService seleniumService;
    private final AfterCrawlService afterCrawlService;

    @GetMapping("/crawl")
    public String crawl() {
        CrawledNaverRestaurant crawl = seleniumService.crawl("7번방", "서울특별시 마포구");
//        CrawledNaverRestaurant crawl = seleniumService.crawl("라멘트럭", "서울특별시 마포구");
//        CrawledNaverRestaurant crawl2 = seleniumService.crawl("소코아", "서울특별시 마포구");
//        CrawledNaverRestaurant crawl3 = seleniumService.crawl("더피자보이즈", "서울특별시 마포구");
//        CrawledNaverRestaurant crawl = seleniumService.crawl("하카타분코", "서울");

        return crawl.toString();
    }

    @GetMapping("/crawl/{restaurantName}")
    public String crawlSpecific (@PathVariable String restaurantName) {
        CrawledNaverRestaurant crawl = seleniumService.crawl(restaurantName, "서울특별시 마포구");
        afterCrawlService.updateRestaurant(restaurantName, "서울특별시 마포구" ,crawl);
        return crawl.toString();
    }
}
