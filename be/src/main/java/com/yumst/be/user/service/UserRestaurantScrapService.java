package com.yumst.be.user.service;

import com.yumst.be.restaurant.domain.Restaurant;
import com.yumst.be.restaurant.repository.RestaurantRepository;
import com.yumst.be.user.domain.UserEntity;
import com.yumst.be.user.domain.UserRestaurantScrap;
import com.yumst.be.user.repository.UserRepository;
import com.yumst.be.user.repository.UserRestaurantScrapRepository;
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
    public UserRestaurantScrap toggleScrap(String userId, String restaurantId) {
        Optional<UserRestaurantScrap> existingScrap = scrapRepository.findByUserIdAndRestaurantId(userId, restaurantId);

        if (existingScrap.isPresent()) {
            scrapRepository.delete(existingScrap.get());
            return existingScrap.get();
        } else {
            UserEntity user = userRepository.findByUserId(userId)
                    .orElseThrow(() -> new IllegalArgumentException("존재하지 않는 사용자입니다."));

            Restaurant restaurant = restaurantRepository.findByRestaurantId(restaurantId)
                    .orElseThrow(() -> new IllegalArgumentException("존재하지 않는 식당입니다."));

            UserRestaurantScrap newScrap = UserRestaurantScrap.builder()
                    .userId(user.getUserId())
                    .restaurantId(restaurant.getRestaurantId())  // UUID 저장
                    .build();

            return scrapRepository.save(newScrap);
        }
    }


}
