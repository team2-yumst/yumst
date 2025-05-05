package com.yumst.be.batch.config.item;

import com.yumst.be.batch.dto.SurveyCompositeData;
import com.yumst.be.batch.dto.SurveyDto;
import com.yumst.be.restaurant.repository.RestaurantRepository;
import com.yumst.be.user.domain.UserEntity;
import com.yumst.be.user.domain.UserPreference;
import com.yumst.be.vote.domain.UserRestaurantVote;
import com.yumst.be.vote.domain.VoteType;
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
import java.util.Objects;
import java.util.function.Function;
import java.util.stream.IntStream;

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


                List<String> restaurantIds = List.of(
                        "18cf887e-a52f-45ee-bf96-80fedbdc8989", // 하카타분코
                        "8fd80f72-9d9d-42ae-900e-b6c019d83cdd", // 닭꼬얌
                        "041ed287-2c07-42ca-868b-83bc69e49bf0", // 알촌 홍대점
                        "e724fad6-b430-4994-8e53-45a14345a82b", // 반라이
                        "399908ea-4720-4a4a-a663-0bd506ca89c1", // 수상한베이글 홍대
                        "bf2eb891-4cac-40b0-afc9-47f5eed3962e", // 비스트로사랑방
                        "32b96508-d5a6-4bab-9d58-4e131099535d", // 통통숯불고기
                        "a8f83289-7d93-4213-a77e-3f755ef88d3d", // KFC
                        "d23fa104-9f14-4c99-8ead-c12dcb7eb87c", // 라멘트럭
                        "f8860585-fda4-4247-9643-d542d254cba5", // 카타코토카페
                        "d71ba9c4-24a0-4f2e-8198-63eb14e9b912", // 45년의정부부대찌개 홍대점
                        "26f2fce9-09fe-4228-a495-24c6dc999234", // 소코아
                        "07fd1f8c-9ca8-42b8-8f7c-ff517d94946e", // 더피자보이즈
                        "1e82ff10-a26f-48f4-a6c7-7ea92e6ec62a", // 멕시코식당
                        "2e972d4c-a1b4-4df4-8b0f-cf1acda88621", // 코노미
                        "3c0fd624-9544-4f41-ad4c-d658eeae0973", // 최강금돈까스
                        "fcc982cf-f194-41d3-9a5d-000ae8990d61", // 더블유오앤
                        "d46e1829-c551-4ac1-bc82-9d1659fce890", // 푸글렌 서울
                        "42dd79f1-6c96-430f-970e-b4f773d8a5a5", // 어리광
                        "ef84a7dc-a740-4e97-8176-1440399ac003", // 바다회사랑
                        "5e075352-4fc6-496e-9641-7f309865bd3b", // 나들목
                        "88a2df05-2641-433e-9509-d2b874bf7549", // 향차이
                        "53bfb7f9-99dd-4575-8c32-eac0d41dcea5", // 산장
                        "0f7313b0-652e-4753-8efa-2c04ecc2cc7a", // 별헤는잔
                        "5b368163-09ce-42f5-ab10-16c83c4aff44"  // 스타벅스 홍대삼거리점
                );

                List<Function<SurveyDto, String>> voteGetters = List.of(
                        SurveyDto::getRestaurantName1,
                        SurveyDto::getRestaurantName2,
                        SurveyDto::getRestaurantName3,
                        SurveyDto::getRestaurantName4,
                        SurveyDto::getRestaurantName5,
                        SurveyDto::getRestaurantName6,
                        SurveyDto::getRestaurantName7,
                        SurveyDto::getRestaurantName8,
                        SurveyDto::getRestaurantName9,
                        SurveyDto::getRestaurantName10,
                        SurveyDto::getRestaurantName11,
                        SurveyDto::getRestaurantName12,
                        SurveyDto::getRestaurantName13,
                        SurveyDto::getRestaurantName14,
                        SurveyDto::getRestaurantName15,
                        SurveyDto::getRestaurantName16,
                        SurveyDto::getRestaurantName17,
                        SurveyDto::getRestaurantName18,
                        SurveyDto::getRestaurantName19,
                        SurveyDto::getRestaurantName20,
                        SurveyDto::getRestaurantName21,
                        SurveyDto::getRestaurantName22,
                        SurveyDto::getRestaurantName23,
                        SurveyDto::getRestaurantName24,
                        SurveyDto::getRestaurantName25
                );

                List<UserRestaurantVote> voteList = IntStream.range(0, restaurantIds.size())
                        .mapToObj(i -> {
                            String vote = voteGetters.get(i).apply(item);
                            if ("좋아요".equals(vote) || "싫어요".equals(vote)) {
                                return UserRestaurantVote.builder()
                                        .userId(user.getUserId())
                                        .restaurantId(restaurantIds.get(i))
                                        .voteType("좋아요".equals(vote)
                                                          ? VoteType.LIKE
                                                          : VoteType.DISLIKE)
                                        .build();
                            }
                            return null;
                        })
                        .filter(Objects::nonNull)
                        .toList();


                return SurveyCompositeData.builder()
                        .userEntity(user)
                        .preferences(collectedPreference)
                        .votes(voteList)
                        .build();
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
