package com.yumst.be.restaurant.config;

import com.yumst.be.restaurant.dto.RestaurantCSVDto;
import org.springframework.batch.item.file.FlatFileItemReader;
import org.springframework.batch.item.file.LineMapper;
import org.springframework.batch.item.file.builder.FlatFileItemReaderBuilder;
import org.springframework.batch.item.file.mapping.BeanWrapperFieldSetMapper;
import org.springframework.batch.item.file.mapping.DefaultLineMapper;
import org.springframework.batch.item.file.transform.DelimitedLineTokenizer;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.ClassPathResource;

@Configuration
public class RestaurantCSVReaderConfig {

    @Bean
    public FlatFileItemReader<RestaurantCSVDto> csvReader() {
        return new FlatFileItemReaderBuilder<RestaurantCSVDto>()
                .name("restaurantCSVReader")
                .encoding("EUC-KR")
                .resource(new ClassPathResource("일반음식점.csv"))

                //test
                .maxItemCount(2000)

                .lineMapper(getMapper())
                .linesToSkip(1)
                .build();
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
