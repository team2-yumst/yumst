package com.yumst.be.user.service;

import com.yumst.be.redis.service.RefreshTokenRedisService;
import com.yumst.be.restaurant.service.RestaurantService;
import com.yumst.be.restaurant.vo.ResponseRestaurant;
import com.yumst.be.user.domain.UserEntity;
import com.yumst.be.user.domain.UserPreference;
import com.yumst.be.user.dto.UserDto;
import com.yumst.be.user.exception.AuthException;
import com.yumst.be.user.repository.UserPreferenceRepository;
import com.yumst.be.user.repository.UserRepository;
import com.yumst.be.user.repository.UserRestaurantScrapRepository;
import lombok.RequiredArgsConstructor;
import org.modelmapper.ModelMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

import static com.yumst.be.user.exception.UserErrorCode.USER_NOT_FOUND;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class UserService {

    private final UserRepository userRepository;
    private final ModelMapper modelMapper;
    private final UserRestaurantScrapRepository userRestaurantScrapRepository;
    private final RestaurantService restaurantService;
    private final UserPreferenceRepository userPreferenceRepository;
    private final RefreshTokenRedisService refreshTokenRedisService;


    @Transactional
    public UserDto registerGuest() {
        UserEntity user = UserEntity.builder()
                                    .build()
                                    .registerGuest();

        userRepository.save(user);
        return modelMapper.map(user, UserDto.class);
    }

    public UserDto getUser(String userId) {
        UserEntity user = userRepository.findByUserId(userId)
                                        .orElseThrow(() -> new AuthException(USER_NOT_FOUND));

        UserDto userDto = modelMapper.map(user, UserDto.class);

        List<String> scrappedId = userRestaurantScrapRepository.findAllRestaurantIdByUserId(userId);
        List<ResponseRestaurant> responseRestaurantList = restaurantService.getResponseRestaurantList(scrappedId, userId);

        userDto.setScrap(responseRestaurantList);
        return userDto;
    }

    @Transactional
    public UserDto deleteUser(String userId) {

        UserEntity user = userRepository.deleteByUserId(userId)
                                        .orElseThrow(() -> new AuthException(USER_NOT_FOUND));

        return modelMapper.map(user, UserDto.class);
    }


    @Transactional
    public void updateAdditionalRegister(String userId, List<String> preferences) {

        UserEntity user = userRepository.findByUserId(userId)
                                        .orElseThrow(() -> new AuthException(USER_NOT_FOUND));

        List<UserPreference> userPreferences = preferences.stream()
                .map(preference -> new UserPreference(user, preference))
                .collect(Collectors.toList());

        userPreferenceRepository.saveAll(userPreferences);
    }

    public void logout(String userId) {
        refreshTokenRedisService.deleteRefreshToken(userId);
    }
}

