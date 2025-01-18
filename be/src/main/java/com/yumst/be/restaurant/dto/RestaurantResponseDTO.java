package com.yumst.be.restaurant.dto;

import java.util.List;

import com.yumst.be.restaurant.domain.Restaurant;
import lombok.*;

@Getter
@Setter
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class RestaurantResponseDTO {

    private String restaurantId;
    private String name;
    private String address;
    private String naverInformation;
    private String openDataInformation;

    public static RestaurantResponseDTO fromEntity(Restaurant restaurant) {
        return RestaurantResponseDTO.builder()
                .restaurantId(restaurant.getRestaurantId())
                .name(restaurant.getName()) // Restaurant 엔티티에 name 필드가 있다고 가정
                .address(restaurant.getAddress().toString()) // Address 객체를 문자열로 변환
                .naverInformation(restaurant.getNaverInformation().toString())
                .openDataInformation(restaurant.getOpenDataInformation().toString())
                .build();
    }
}
