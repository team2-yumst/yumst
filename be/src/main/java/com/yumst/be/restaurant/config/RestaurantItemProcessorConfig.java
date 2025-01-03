package com.yumst.be.restaurant.config;


import com.yumst.be.restaurant.domain.Restaurant;
import com.yumst.be.restaurant.dto.RestaurantCSVDto;
import lombok.RequiredArgsConstructor;
import org.modelmapper.ModelMapper;
import org.springframework.batch.item.ItemProcessor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.UUID;

@Configuration
@RequiredArgsConstructor
public class RestaurantItemProcessorConfig {

    private final ModelMapper modelMapper;

    @Bean
    public ItemProcessor<RestaurantCSVDto, Restaurant> restaurantItemProcessor() {
        return new ItemProcessor<RestaurantCSVDto, Restaurant>() {
            @Override
            public Restaurant process(RestaurantCSVDto item) throws Exception {
                item.setRestaurantId(UUID.randomUUID().toString());
                return modelMapper.map(item, Restaurant.class);
            }
        };
    }
}
