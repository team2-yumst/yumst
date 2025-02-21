package com.yumst.be.batch.config.item;

import com.yumst.be.batch.dto.RestaurantCSVDto;
import com.yumst.be.restaurant.domain.Restaurant;
import jakarta.persistence.EntityManagerFactory;
import lombok.RequiredArgsConstructor;
import org.springframework.batch.item.database.JpaPagingItemReader;
import org.springframework.batch.item.file.FlatFileItemReader;
import org.springframework.batch.item.file.LineMapper;
import org.springframework.batch.item.file.builder.FlatFileItemReaderBuilder;
import org.springframework.batch.item.file.mapping.BeanWrapperFieldSetMapper;
import org.springframework.batch.item.file.mapping.DefaultLineMapper;
import org.springframework.batch.item.file.transform.DelimitedLineTokenizer;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.ClassPathResource;

import java.util.Map;

@Configuration
@RequiredArgsConstructor
public class RestaurantReaderConfig {

    private final EntityManagerFactory entityManagerFactory;

    @Bean
    public FlatFileItemReader<RestaurantCSVDto> csvReader() {
        return new FlatFileItemReaderBuilder<RestaurantCSVDto>()
                .name("restaurantCSVReader")
                .encoding("EUC-KR")
                .resource(new ClassPathResource("일반음식점.csv"))

                .lineMapper(getMapper())
                .linesToSkip(1)
                .build();
    }

    @Bean
    public FlatFileItemReader<RestaurantCSVDto> csvReader2() {
        return new FlatFileItemReaderBuilder<RestaurantCSVDto>()
                .name("restaurantCSVReader")
                .encoding("EUC-KR")
                .resource(new ClassPathResource("휴게음식점.csv"))

                .lineMapper(getMapper())
                .linesToSkip(1)
                .build();
    }

    // 현재는 서울만 읽는 reader
    @Bean
    public JpaPagingItemReader<Restaurant> dbRestaurantReader() {

        JpaPagingItemReader<Restaurant> reader = new JpaPagingItemReader<>();
        reader.setEntityManagerFactory(entityManagerFactory);
        reader.setPageSize(5);

        reader.setMaxItemCount(300);


        reader.setQueryString("SELECT r FROM Restaurant r " +
                                      "WHERE r.openDataInformation.fullAddress LIKE :address" +
                                      " AND r.crawlComplete = false" +
                                      " AND r.restaurantId NOT IN (SELECT f.recordDataId FROM FailedRecord f)");
        reader.setParameterValues(Map.of("address", "%마포구%"));

        return reader;
    }


    // 전국 데이터를 읽는 reader : 나중에 사용
    @Bean
    public JpaPagingItemReader<Restaurant> dbRestaurantReaderEntireData() {
        JpaPagingItemReader<Restaurant> reader = new JpaPagingItemReader<>();
        reader.setEntityManagerFactory(entityManagerFactory);
        reader.setPageSize(10);

        reader.setQueryString("SELECT r FROM Restaurant r " +
                             "WHERE r.crawlComplete = false");

        return reader;
    }



    private LineMapper<RestaurantCSVDto> getMapper() {
        DelimitedLineTokenizer tokenizer = getLineTokenizer();
        BeanWrapperFieldSetMapper<RestaurantCSVDto> fieldSetMapper = getFieldSetMapper();
        return getLineMapper(tokenizer, fieldSetMapper);
    }

    private DelimitedLineTokenizer getLineTokenizer() {
        DelimitedLineTokenizer tokenizer = new DelimitedLineTokenizer();
        tokenizer.setQuoteCharacter('"');
        tokenizer.setDelimiter(",");
        tokenizer.setStrict(false);
        tokenizer.setNames("dataId", "serviceName", "serviceId", "municipalityCode", "managementNumber", "authorizationDate",
                           "authorizationCancelDate", "businessStatusCode", "businessStatusName", "detailedBusinessStatusCode",
                           "detailedBusinessStatusName", "closureDate", "suspensionStartDate", "suspensionEndDate", "reopeningDate",
                           "contactNumber", "areaSize", "postalCode", "fullAddress", "roadNameFullAddress", "roadNamePostalCode",
                           "businessName", "lastModified", "dataUpdateType", "dataUpdateDate", "businessTypeName", "coordinateX",
                           "coordinateY", "sanitationBusinessType", "numberOfMaleEmployees", "numberOfFemaleEmployees",
                           "businessSurroundings", "gradeClassification", "waterSupplyClassification", "totalEmployees",
                           "headOfficeEmployees", "factoryOfficeEmployees", "factorySalesEmployees", "factoryProductionEmployees",
                           "buildingOwnership", "deposit", "monthlyRent", "isMultiUseFacility", "totalFacilityScale",
                           "traditionalBusinessDesignationNumber", "mainFoodOfTraditionalBusiness", "website");
        return tokenizer;
    }

    private BeanWrapperFieldSetMapper<RestaurantCSVDto> getFieldSetMapper() {
        BeanWrapperFieldSetMapper<RestaurantCSVDto> fieldSetMapper = new BeanWrapperFieldSetMapper<>();
        fieldSetMapper.setTargetType(RestaurantCSVDto.class);
        return fieldSetMapper;
    }

    private DefaultLineMapper<RestaurantCSVDto> getLineMapper(DelimitedLineTokenizer tokenizer, BeanWrapperFieldSetMapper<RestaurantCSVDto> fieldSetMapper) {
        DefaultLineMapper<RestaurantCSVDto> lineMapper = new DefaultLineMapper<>();
        lineMapper.setLineTokenizer(tokenizer);
        lineMapper.setFieldSetMapper(fieldSetMapper);
        return lineMapper;
    }

}
