package com.yumst.be.user.domain;

import lombok.Getter;
import lombok.RequiredArgsConstructor;

@RequiredArgsConstructor
@Getter
public enum Tendency {

    VERY_STABLE(0),
    STABLE(1),
    NORMAL(2),
    ADVENTUROUS(3),
    VERY_ADVENTUROUS(4);

    private final int value;

}
