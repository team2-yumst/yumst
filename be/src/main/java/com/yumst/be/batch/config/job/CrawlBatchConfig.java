package com.yumst.be.batch.config.job;

import com.yumst.be.batch.config.item.RestaurantProcessorConfig;
import com.yumst.be.batch.config.item.RestaurantReaderConfig;
import com.yumst.be.batch.config.item.RestaurantWriterConfig;
import com.yumst.be.batch.config.listener.RestaurantProcessListener;
import com.yumst.be.batch.config.listener.RestaurantWriteListener;
import com.yumst.be.restaurant.domain.Restaurant;
import lombok.RequiredArgsConstructor;
import org.springframework.batch.core.Job;
import org.springframework.batch.core.Step;
import org.springframework.batch.core.job.builder.JobBuilder;
import org.springframework.batch.core.launch.support.RunIdIncrementer;
import org.springframework.batch.core.repository.JobRepository;
import org.springframework.batch.core.step.builder.StepBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.transaction.PlatformTransactionManager;

@Configuration
@RequiredArgsConstructor
public class CrawlBatchConfig {

    private final JobRepository jobRepository;
    private final PlatformTransactionManager transactionManager;
    private final RestaurantReaderConfig restaurantReaderConfig;
    private final RestaurantProcessorConfig restaurantProcessorConfig;
    private final RestaurantWriterConfig restaurantWriterConfig;

    private final RestaurantProcessListener restaurantProcessListener;
    private final RestaurantWriteListener restaurantWriteListener;

    @Bean
    public Job crawlJob() {
        return new JobBuilder("crawlJob", jobRepository)
                .incrementer(new RunIdIncrementer())
                .start(crawlStep())
                .build();
    }

    @Bean
    public Step crawlStep() {
        return new StepBuilder("crawlStep", jobRepository)
                .<Restaurant, Restaurant>chunk(1, transactionManager)
                .reader(restaurantReaderConfig.dbRestaurantReader())
                .processor(restaurantProcessorConfig.db2DBCrawlProcessor())
                .writer(restaurantWriterConfig.restaurantItemWriter())

//                .taskExecutor(new SimpleAsyncTaskExecutor()) // 병렬처리

                .faultTolerant()
                .skip(Exception.class)
                .skipLimit(100)

                // 실패 레코드 기록
                .listener(restaurantProcessListener)
                .listener(restaurantWriteListener)

                .build();
    }


}
