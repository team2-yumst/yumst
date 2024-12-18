package com.yumst.be.user.domain;

import lombok.Getter;
import lombok.RequiredArgsConstructor;

@RequiredArgsConstructor
@Getter
public enum AgeRange {

    TEENAGER("10대"),
    TWENTIES("20대"),
    THIRTIES("30대"),
    FORTIES("40대"),
    FIFTIES("50대"),
    SIXTIES("60대"),
    SEVENTIES("70대"),
    EIGHTIES("80대"),
    NINETIES("90대"),
    OVER_HUNDRED("100세 이상");

    private final String value;

}
