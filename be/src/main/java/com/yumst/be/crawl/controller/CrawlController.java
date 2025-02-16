package com.yumst.be.crawl.controller;

import com.yumst.be.crawl.dto.CrawledNaverRestaurant;
import com.yumst.be.crawl.service.SeleniumService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
public class CrawlController {

    private final SeleniumService seleniumService;

    @GetMapping("/crawl")
    public String crawl() {
        CrawledNaverRestaurant crawl = seleniumService.crawl("이호커피", "서울특별시 마포구 망원동");
//        CrawledNaverRestaurant crawl = seleniumService.crawl("하카타분코", "서울");

        return crawl.toString();
    }
}
