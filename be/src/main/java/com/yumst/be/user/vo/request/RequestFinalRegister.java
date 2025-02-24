package com.yumst.be.user.vo.request;

import lombok.Data;

import java.util.List;

@Data
public class RequestFinalRegister {
    private List<String> preferences;
}
