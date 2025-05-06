package com.yumst.be.user.service;

import com.yumst.be.restaurant.repository.RestaurantRepository;
import com.yumst.be.user.domain.UserRestaurantScrap;
import com.yumst.be.user.repository.UserRepository;
import com.yumst.be.user.repository.UserRestaurantScrapRepository;
import com.yumst.be.user.vo.response.ResponseScrap;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;

@Service
@RequiredArgsConstructor
public class UserRestaurantScrapService {

    private final UserRestaurantScrapRepository scrapRepository;
    private final UserRepository userRepository;
    private final RestaurantRepository restaurantRepository;

    @Transactional
    public ResponseScrap toggleScrap(String userId, String restaurantId) {
        // 기존 스크랩 여부 확인
        Optional<UserRestaurantScrap> existingScrap = scrapRepository.findByUserIdAndRestaurantId(userId, restaurantId);
        checkPresentUserRestaurant(userId, restaurantId);

        if (existingScrap.isPresent()) {
            // 이미 스크랩된 경우 삭제
            scrapRepository.delete(existingScrap.get());
            return new ResponseScrap(userId, restaurantId, false);
        } else {
            // 스크랩되지 않은 경우 추가
            UserRestaurantScrap newScrap = UserRestaurantScrap.builder()
                    .userId(userId)
                    .restaurantId(restaurantId)
                    .build();
            scrapRepository.save(newScrap);
            return new ResponseScrap(userId, restaurantId, true);
        }
    }

    private void checkPresentUserRestaurant(String userId, String restaurantId) {
        // 유저 조회
        userRepository.findByUserId(userId)
                .orElseThrow(() -> new IllegalArgumentException("존재하지 않는 사용자입니다."));

        // 식당 조회
        restaurantRepository.findByRestaurantId(restaurantId)
                .orElseThrow(() -> new IllegalArgumentException("존재하지 않는 식당입니다."));
    }
}