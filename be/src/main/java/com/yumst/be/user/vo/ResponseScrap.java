package com.yumst.be.user.vo;

import com.yumst.be.restaurant.domain.Restaurant;
import lombok.Data;

import java.util.List;

@Data
public class ResponseScrap {

    private String userId;
    private String restaurantId;

    private List<Restaurant> scrap;
}
