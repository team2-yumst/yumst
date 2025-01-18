package com.yumst.be.recommendation.service;

import com.yumst.be.restaurant.domain.Restaurant;
import com.yumst.be.restaurant.repository.RestaurantRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class RecommendationService {

    private final RestaurantRepository restaurantRepository;

    public List<Restaurant> getNearbyRestaurants(String userId, double userLat, double userLng) {
        // 모든 식당 정보 가져오기
        List<Restaurant> allRestaurants = restaurantRepository.findAll();

        // 거리 계산 및 정렬
        return allRestaurants.stream()
                .filter(restaurant -> restaurant.getNaverInformation() != null)
                .sorted((r1, r2) -> {
                    double distance1 = calculateDistance(userLat, userLng,
                            Double.parseDouble(r1.getNaverInformation().getLatitude()),
                            Double.parseDouble(r1.getNaverInformation().getLongitude()));
                    double distance2 = calculateDistance(userLat, userLng,
                            Double.parseDouble(r2.getNaverInformation().getLatitude()),
                            Double.parseDouble(r2.getNaverInformation().getLongitude()));
                    return Double.compare(distance1, distance2);
                })
                .limit(20) // 가까운 20개만 반환
                .collect(Collectors.toList());
    }

    // 하버사인 공식을 사용하여 거리 계산 (단위: km)
    private double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
        final int R = 6371; // 지구 반지름 (단위: km)
        double dLat = Math.toRadians(lat2 - lat1);
        double dLon = Math.toRadians(lon2 - lon1);
        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2)
                + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2))
                * Math.sin(dLon / 2) * Math.sin(dLon / 2);
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        return R * c; // 결과: 거리 (km)
    }
}
