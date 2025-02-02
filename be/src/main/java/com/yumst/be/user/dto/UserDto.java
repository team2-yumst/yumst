package com.yumst.be.user.dto;

import com.yumst.be.restaurant.domain.Restaurant;
import lombok.Data;

import java.util.List;

@Data
public class UserDto {
    private String userId;
    private String name;
    private String email;



    private List<Restaurant> scrap;
}
