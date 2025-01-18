package com.yumst.be.restaurant.domain;

import com.yumst.be.global.entity.BaseTimeEntity;
import com.yumst.be.restaurant.domain.embed.Address;
import com.yumst.be.restaurant.domain.embed.NaverInformation;
import com.yumst.be.restaurant.domain.embed.OpenDataInformation;
import jakarta.persistence.*;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.util.UUID;

import static jakarta.persistence.GenerationType.IDENTITY;
import static lombok.AccessLevel.PROTECTED;

@Entity
@Table(name = "restaurant")
@NoArgsConstructor(access = PROTECTED)
@Getter
public class Restaurant extends BaseTimeEntity {

    @Id
    @GeneratedValue(strategy = IDENTITY)
    private Long id;

    @Column(unique = true, nullable = false)
    private String restaurantId;

    @Column(nullable = false)
    private String name;

    @Embedded
    private Address address;

    @Embedded
    private OpenDataInformation openDataInformation;

    @Embedded
    private NaverInformation naverInformation;

    @Builder
    public Restaurant(Address address, String name, OpenDataInformation openDataInformation, NaverInformation naverInformation) {
        this.restaurantId = UUID.randomUUID().toString();
        this.address = address;
        this.name = name;
        this.openDataInformation = openDataInformation;
        this.naverInformation = naverInformation;
    }
}
