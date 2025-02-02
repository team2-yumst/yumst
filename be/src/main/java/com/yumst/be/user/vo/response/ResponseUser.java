package com.yumst.be.user.vo.response;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.yumst.be.restaurant.domain.Restaurant;
import lombok.Data;

import java.util.List;

import static com.fasterxml.jackson.annotation.JsonInclude.Include.NON_NULL;

@Data
@JsonInclude(NON_NULL)
public class ResponseUser {

    private String userId;
    private String email;
    private String name;

    private List<Restaurant> scrap;
}
