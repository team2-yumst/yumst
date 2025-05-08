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
        return UserDto.from(user);
    }

    public UserDto findUserWithScrappedRestaurant(String userId) {
        UserEntity user = findUserOrThrow(userId);

        UserDto userDto = UserDto.from(user);
        findUserTermsInfo(userDto, user);
        findScrappedRestaurant(userId, userDto);

        return userDto;
    }

    @Transactional
    public UserDto deleteUser(String userId) {

        UserEntity user = userRepository.findByUserId(userId)
                                        .orElseThrow(() -> new AuthException(USER_NOT_FOUND));

        userRepository.delete(user);

        return UserDto.from(user);
    }


    @Transactional
    public void updateSurveyInfo(String userId, List<String> preferences) {

        UserEntity user = findUserOrThrow(userId);

        List<UserPreference> userPreferences = preferences.stream()
                .map(preference -> new UserPreference(user, preference))
                .collect(Collectors.toList());

        user.finishedSurvey();
        user.finishRegisterAndEnable();

        userPreferenceRepository.saveAll(userPreferences);
    }

    @Transactional
    public void updateAgreeTerms(String userId) {

        UserEntity user = findUserOrThrow(userId);

        user.updateAgreeTerms();
    }

    public void logout(String userId) {
        refreshTokenRedisService.deleteRefreshToken(userId);
    }


    private void findScrappedRestaurant(String userId, UserDto userDto) {
        List<String> scrappedId = userRestaurantScrapRepository.findAllRestaurantIdByUserId(userId);
        List<ResponseRestaurant> responseRestaurantList = restaurantService.getResponseRestaurantList(scrappedId, userId);

        userDto.setScrap(responseRestaurantList);
    }

    private void findUserTermsInfo(UserDto userDto, UserEntity user) {
        userDto.setFinishedSurvey(user.getUserTerms().isFinishedSurvey());
        userDto.setAgreedLocationTerms(user.getUserTerms().isAgreedLocationTerms());
        userDto.setAgreedPrivacyPolicy(user.getUserTerms().isAgreedPrivacyPolicy());
        userDto.setAgreedTermsOfService(user.getUserTerms().isAgreedTermsOfService());
    }

    private UserEntity findUserOrThrow(String userId) {
        return userRepository.findByUserId(userId)
                .orElseThrow(() -> new AuthException(USER_NOT_FOUND));
    }

}

