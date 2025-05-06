package com.yumst.be.user.vo.request;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class RequestUser {

    @Email
    @NotNull
    private String email;


}
