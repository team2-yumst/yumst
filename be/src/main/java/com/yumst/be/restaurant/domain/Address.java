package com.yumst.be.restaurant.domain;

import jakarta.persistence.Embeddable;

@Embeddable
public class Address {
    private String city;
    private String gu;
    private String street;
    private String streetDetail;
    private String dong;
    private String dongDetail;
    private String postCode;
}
