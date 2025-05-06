package com.yumst.be.user.dto;

import lombok.Data;

import java.util.List;

@Data
public class UserRestaurantDto {

    private String userId;
    private List<String> restaurantIds;

}
