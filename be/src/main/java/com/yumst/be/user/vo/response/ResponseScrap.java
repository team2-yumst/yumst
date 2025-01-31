package com.yumst.be.user.vo.response;

import com.yumst.be.restaurant.domain.Restaurant;
import lombok.Data;

import java.util.List;

@Data
public class ResponseScrap {

    private String userId;
    private String restaurantId;

    private List<Restaurant> scrap;
}
