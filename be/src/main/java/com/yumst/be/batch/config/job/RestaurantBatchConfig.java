package com.yumst.be.batch.config.job;

import com.yumst.be.batch.config.item.RestaurantProcessorConfig;
import com.yumst.be.batch.config.item.RestaurantReaderConfig;
import com.yumst.be.batch.config.item.RestaurantWriterConfig;
import com.yumst.be.batch.dto.RestaurantCSVDto;
import com.yumst.be.restaurant.domain.Restaurant;
import lombok.RequiredArgsConstructor;
import org.springframework.batch.core.Job;
import org.springframework.batch.core.Step;
import org.springframework.batch.core.job.builder.JobBuilder;
import org.springframework.batch.core.repository.JobRepository;
import org.springframework.batch.core.step.builder.StepBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.transaction.PlatformTransactionManager;

@Configuration
@RequiredArgsConstructor
public class RestaurantBatchConfig {

    private final JobRepository jobRepository;
    private final PlatformTransactionManager transactionManager;
    private final RestaurantReaderConfig restaurantReaderConfig;
    private final RestaurantProcessorConfig restaurantProcessorConfig;
    private final RestaurantWriterConfig restaurantWriterConfig;

    @Bean
    public Job restaurantCSVJob() {
        return new JobBuilder("restaurantJob", jobRepository)
                .start(restaurantCSVStep())
                .next(restaurantCSVStep2())
                .build();
    }


    @Bean
    public Step restaurantCSVStep() {
        return new StepBuilder("일반음식점 추가 step", jobRepository)
                .<RestaurantCSVDto, Restaurant>chunk(1000, transactionManager)
                .reader(restaurantReaderConfig.csvReader())
                .processor(restaurantProcessorConfig.csv2DBProcessor())
                .writer(restaurantWriterConfig.restaurantItemWriter())
                .build();
    }

    @Bean
    public Step restaurantCSVStep2() {
        return new StepBuilder("휴게음식점 추가 step", jobRepository)
                .<RestaurantCSVDto, Restaurant>chunk(1000, transactionManager)
                .reader(restaurantReaderConfig.csvReader2())
                .processor(restaurantProcessorConfig.csv2DBProcessor())
                .writer(restaurantWriterConfig.restaurantItemWriter())
                .build();
    }


}
