package com.yumst.be.batch.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.batch.core.JobParameters;
import org.springframework.batch.core.JobParametersBuilder;
import org.springframework.batch.core.configuration.JobRegistry;
import org.springframework.batch.core.launch.JobLauncher;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
@RequestMapping("/batch")
public class BatchController {

    private final JobLauncher jobLauncher;
    private final JobRegistry jobRegistry;


    @GetMapping("/start")
    public String startBatch() {

        JobParameters time = new JobParametersBuilder()
                .addLong("time", System.currentTimeMillis())
                .toJobParameters();

        try {
            jobLauncher.run(jobRegistry.getJob("restaurantJob"), time);
        } catch (Exception e) {
            e.printStackTrace();
        }

        return "ok";
    }

    @GetMapping("/crawl")
    public String startCrawl() {

        JobParameters time = new JobParametersBuilder()
                .addLong("time", System.currentTimeMillis())
                .toJobParameters();

        try {
            jobLauncher.run(jobRegistry.getJob("crawlJob"), time);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return "ok";
    }
}
