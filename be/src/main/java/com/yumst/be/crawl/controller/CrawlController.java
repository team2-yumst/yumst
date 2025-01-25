package com.yumst.be.crawl.controller;

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
        seleniumService.crawl("후라토 식당 ", "서울");
        seleniumService.crawl("하카타분코", "서울");

        return "crawl";
    }
}
