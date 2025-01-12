package com.yumst.be.user.vo;

import com.yumst.be.user.domain.AgeRange;
import com.yumst.be.user.domain.Gender;
import com.yumst.be.user.domain.Tendency;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class RequestUser {

    @Email
    @NotNull
    private String email;

    @NotNull
    private Gender gender;

    @NotNull
    private AgeRange ageRange;

    @NotNull
    private Tendency tendency;
}
