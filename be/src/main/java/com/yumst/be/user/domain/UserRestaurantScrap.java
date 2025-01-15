package com.yumst.be.user.domain;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.Id;
import lombok.Builder;
import lombok.RequiredArgsConstructor;

import static jakarta.persistence.GenerationType.IDENTITY;
import static lombok.AccessLevel.*;

@Entity
@RequiredArgsConstructor(access = PROTECTED)
public class UserRestaurantScrap {

    @Id @GeneratedValue(strategy = IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String userId;

    @Column(nullable = false)
    private String restaurantId;

    @Builder
    public UserRestaurantScrap(String userId, String restaurantId) {
        this.userId = userId;
        this.restaurantId = restaurantId;
    }
}
