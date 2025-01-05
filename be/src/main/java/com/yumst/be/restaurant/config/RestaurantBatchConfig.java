package com.yumst.be.restaurant.config;

import com.yumst.be.restaurant.domain.Restaurant;
import com.yumst.be.restaurant.dto.RestaurantCSVDto;
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
    private final RestaurantCSVReaderConfig restaurantCSVReaderConfig;
    private final RestaurantItemProcessorConfig restaurantItemProcessorConfig;
    private final RestaurantItemWriterConfig restaurantItemWriterConfig;

    @Bean
    public Job restaurantCSVJob() {
        return new JobBuilder("restaurantJob", jobRepository)
                .start(restaurantCSVStep())
                .build();
    }

    @Bean
    public Step restaurantCSVStep() {
        return new StepBuilder("restaurantStep", jobRepository)
                .<RestaurantCSVDto, Restaurant>chunk(1000, transactionManager)
                .reader(restaurantCSVReaderConfig.csvReader())
                .processor(restaurantItemProcessorConfig.restaurantItemProcessor())
                .writer(restaurantItemWriterConfig.restaurantItemWriter())
                .build();
    }


}
