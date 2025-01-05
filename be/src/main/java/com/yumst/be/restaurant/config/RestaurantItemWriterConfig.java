package com.yumst.be.restaurant.config;

import com.yumst.be.restaurant.domain.Restaurant;
import jakarta.persistence.EntityManagerFactory;
import lombok.RequiredArgsConstructor;
import org.springframework.batch.item.database.JpaItemWriter;
import org.springframework.batch.item.database.builder.JpaItemWriterBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
@RequiredArgsConstructor
public class RestaurantItemWriterConfig {

    private final EntityManagerFactory entityManagerFactory;

    @Bean
    public JpaItemWriter<Restaurant> restaurantItemWriter() {
        return new JpaItemWriterBuilder<Restaurant>()
                .entityManagerFactory(entityManagerFactory)
                .build();
    }

}
