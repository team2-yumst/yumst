package com.yumst.be.batch.config.item;

import com.yumst.be.batch.dto.SurveyCompositeData;
import com.yumst.be.batch.dto.SurveyDto;
import com.yumst.be.restaurant.repository.RestaurantRepository;
import com.yumst.be.user.domain.UserEntity;
import com.yumst.be.user.domain.UserPreference;
import jakarta.persistence.EntityManagerFactory;
import lombok.RequiredArgsConstructor;
import org.springframework.batch.item.ItemProcessor;
import org.springframework.batch.item.file.FlatFileItemReader;
import org.springframework.batch.item.file.LineMapper;
import org.springframework.batch.item.file.builder.FlatFileItemReaderBuilder;
import org.springframework.batch.item.file.mapping.BeanWrapperFieldSetMapper;
import org.springframework.batch.item.file.mapping.DefaultLineMapper;
import org.springframework.batch.item.file.transform.DelimitedLineTokenizer;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.ClassPathResource;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

@Configuration
@RequiredArgsConstructor
public class SurveyConfig {

    private final EntityManagerFactory entityManagerFactory;

    private final RestaurantRepository restaurantRepository;

    @Bean
    public FlatFileItemReader<SurveyDto> surveyReader() {
        return new FlatFileItemReaderBuilder<SurveyDto>()
                .name("surveyCSVReader")
                .encoding("UTF-8")
                .resource(new ClassPathResource("yums설문결과.csv"))

                .lineMapper(getMapper())
                .linesToSkip(1)
                .build();
    }

    @Bean
    public ItemProcessor<SurveyDto, SurveyCompositeData> surveyProcessor() {
        return new ItemProcessor<SurveyDto, SurveyCompositeData> () {
            @Override
            public SurveyCompositeData process(SurveyDto item) throws Exception {

                UserEntity user = UserEntity.builder()
                        .build()
                        .registerGuest();

                List<String> preferences = new ArrayList<>();
                preferences.addAll(Arrays.asList(item.getSurveyFirst().split(";")));
                preferences.addAll(Arrays.asList(item.getSurveySecond().split(";")));
                preferences.addAll(Arrays.asList(item.getSurveyThird().split(";")));

                List<UserPreference> collectedPreference = preferences.stream()
                        .map(preference -> new UserPreference(user, preference))
                        .toList();




                return null;
            }
        };
    }


    private LineMapper<SurveyDto> getMapper() {
        DelimitedLineTokenizer tokenizer = getLineTokenizer();
        BeanWrapperFieldSetMapper<SurveyDto> fieldSetMapper = getFieldSetMapper();
        return getLineMapper(tokenizer, fieldSetMapper);
    }


    private DelimitedLineTokenizer getLineTokenizer() {
        DelimitedLineTokenizer tokenizer = new DelimitedLineTokenizer();
        tokenizer.setQuoteCharacter('"');
        tokenizer.setDelimiter(",");
        tokenizer.setStrict(false);
        tokenizer.setNames("timeStamp", "surveyFirst", "surveySecond", "SurveyThird", "restaurantName1", "restaurantName2", "restaurantName3", "restaurantName4", "restaurantName5", "restaurantName6", "restaurantName7", "restaurantName8", "restaurantName9", "restaurantName10", "restaurantName11", "restaurantName12", "restaurantName13", "restaurantName14", "restaurantName15", "restaurantName16", "restaurantName17", "restaurantName18", "restaurantName19", "restaurantName20", "restaurantName21", "restaurantName22", "restaurantName23", "restaurantName24", "restaurantName25");
        return tokenizer;
    }

    private BeanWrapperFieldSetMapper<SurveyDto> getFieldSetMapper() {
        BeanWrapperFieldSetMapper<SurveyDto> fieldSetMapper = new BeanWrapperFieldSetMapper<>();
        fieldSetMapper.setTargetType(SurveyDto.class);
        return fieldSetMapper;
    }

    private DefaultLineMapper<SurveyDto> getLineMapper(DelimitedLineTokenizer tokenizer, BeanWrapperFieldSetMapper<SurveyDto> fieldSetMapper) {
        DefaultLineMapper<SurveyDto> lineMapper = new DefaultLineMapper<>();
        lineMapper.setLineTokenizer(tokenizer);
        lineMapper.setFieldSetMapper(fieldSetMapper);
        return lineMapper;
    }



}
