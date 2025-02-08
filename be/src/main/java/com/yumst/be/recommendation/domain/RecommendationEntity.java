package com.yumst.be.recommendation.domain;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.util.UUID;

@Entity
@Table(name = "recommendation")
@Getter
@NoArgsConstructor
public class RecommendationEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private UUID id;

    @Column(name = "restaurant_id")
    private UUID restaurantId;

    @Column(name = "user_id")
    private UUID userId;

}
