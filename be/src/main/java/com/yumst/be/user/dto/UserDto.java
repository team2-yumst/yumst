package com.yumst.be.user.dto;

import com.yumst.be.user.domain.AgeRange;
import com.yumst.be.user.domain.Gender;
import com.yumst.be.user.domain.Tendency;
import lombok.Data;

@Data
public class UserDto {
    private String userId;
    private String name;
    private String email;

    private Gender gender;
    private AgeRange ageRange;
    private Tendency tendency;
}
