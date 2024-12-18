package com.yumst.be.restaurant.domain;

import com.yumst.be.global.entity.BaseTimeEntity;
import jakarta.persistence.*;


import static jakarta.persistence.FetchType.*;
import static jakarta.persistence.GenerationType.*;

@Entity
@Table(name = "restaurant")
public class Restaurant extends BaseTimeEntity {

    @Id @GeneratedValue(strategy = IDENTITY)
    private Long id;

    @Column(unique = true, nullable = false)
    private String restaurantId;

    // TODO: 음식점을 추가할때 카테고리가 존재하지 않으면 카테고리도 추가
    @ManyToOne(fetch = LAZY)
    @JoinColumn(name = "category_id")
    private Category category;

    @Embedded
    private Address address;

    @Embedded
    private OpenDataInformation openDataInformation;

    // https://developers.google.com/maps/documentation/places/web-service/data-fields?hl=en&_gl=1*k1h049*_up*MQ..*_ga*MTY3NDEyMzU2NC4xNzMxODMzNTEx*_ga_NRWSTWS78N*MTczMTgzMzUxMS4xLjEuMTczMTgzMzUzOC4wLjAuMA
    @Embedded
    private GoogleInformation googleInformation;

}
