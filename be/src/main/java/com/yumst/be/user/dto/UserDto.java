package com.yumst.be.user.dto;

import com.yumst.be.restaurant.vo.ResponseRestaurant;
import lombok.Data;

import java.util.List;

@Data
public class UserDto {
    private String userId;
    private String name;
    private String email;

    private String imageUrl;

    private List<ResponseRestaurant> scrap;
}
