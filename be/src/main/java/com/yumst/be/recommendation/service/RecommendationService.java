package com.yumst.be.recommendation.service;

import com.yumst.be.recommendation.repository.RecommendationRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class RecommendationService {
    private final RecommendationRepository recommendationRepository;

    @Transactional(readOnly = true)
    public List<UUID> getRecommendedRestaurants(UUID userId) {
        return recommendationRepository.findRecommendations(userId)
                .stream()
                .map(UUID::fromString)
                .collect(Collectors.toList());
    }
}
