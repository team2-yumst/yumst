package com.yumst.be.batch.config.job;

import com.yumst.be.batch.config.item.SurveyConfig;
import com.yumst.be.batch.config.item.SurveyWriter;
import com.yumst.be.batch.dto.SurveyCompositeData;
import com.yumst.be.batch.dto.SurveyDto;
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
public class SurveyBatchConfig {

    private final JobRepository jobRepository;
    private final PlatformTransactionManager transactionManager;
    private final SurveyConfig surveyConfig;
    private final SurveyWriter surveyWriter;

    @Bean
    public Job surveyJob() {
        return new JobBuilder("surveyJob", jobRepository)
                .incrementer(new RunIdIncrementer())
                .start(addSurveyDataStep())
                .build();
    }

    @Bean
    public Step addSurveyDataStep() {
        return new StepBuilder("설문 데이터 추가 step", jobRepository)
                .<SurveyDto, SurveyCompositeData> chunk(20, transactionManager)
                .reader(surveyConfig.surveyReader())
                .processor(surveyConfig.surveyProcessor())
                .writer(surveyWriter)
                .build();
    }


}
