package com.yumst.be.batch.config;


import com.yumst.be.restaurant.domain.embed.OpenDataInformation;
import com.yumst.be.restaurant.domain.Restaurant;
import com.yumst.be.batch.dto.RestaurantCSVDto;
import lombok.RequiredArgsConstructor;
import org.modelmapper.ModelMapper;
import org.springframework.batch.item.ItemProcessor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
@RequiredArgsConstructor
public class RestaurantItemProcessorConfig {

    private final ModelMapper modelMapper;

    @Bean
    public ItemProcessor<RestaurantCSVDto, Restaurant> restaurantItemProcessor() {
        return new ItemProcessor<RestaurantCSVDto, Restaurant>() {
            @Override
            public Restaurant process(RestaurantCSVDto item) throws Exception {

                if (item.getBusinessStatusName().equals("폐업")) {
                    return null;
                }

                OpenDataInformation openDataInformation = modelMapper.map(item, OpenDataInformation.class);
                return Restaurant.builder()
                        .openDataInformation(openDataInformation)
                        .build();
            }
        };
    }
}
