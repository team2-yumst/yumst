package com.yumst.be.user.vo;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Data;

import static com.fasterxml.jackson.annotation.JsonInclude.Include.*;

@Data
@JsonInclude(NON_NULL)
public class ResponseUser {

    private String userId;
    private String email;
    private String name;

}
