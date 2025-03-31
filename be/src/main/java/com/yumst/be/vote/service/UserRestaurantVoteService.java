package com.yumst.be.vote.service;

import com.yumst.be.vote.domain.UserRestaurantVote;
import com.yumst.be.vote.repository.UserRestaurantVoteRepository;
import com.yumst.be.vote.dto.ResponseRestaurant;
import com.yumst.be.vote.dto.VoteResponse;
import com.yumst.be.vote.dto.VoteType;
import com.yumst.be.vote.exception.VoteErrorCode;
import com.yumst.be.vote.exception.VoteException;
import com.yumst.be.restaurant.repository.RestaurantRepository;
import com.yumst.be.restaurant.repository.NaverReviewFeatureCountRepository;
import com.yumst.be.user.repository.UserRestaurantScrapRepository;
import com.yumst.be.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class UserRestaurantVoteService {
    private final UserRestaurantVoteRepository userRestaurantVoteRepository;
    private final RestaurantRepository restaurantRepository;
    private final UserRestaurantScrapRepository userRestaurantScrapRepository;
    private final NaverReviewFeatureCountRepository naverReviewFeatureCountRepository;
    private final UserRepository userRepository;

    @Transactional(readOnly = true)
    public List<ResponseRestaurant> getVotableRestaurants(String userId, Double latitude, Double longitude, Double radius, String sort, int page) {
        // 사용자 존재 여부 확인
        userRepository.findByUserId(userId)
                .orElseThrow(() -> new VoteException(VoteErrorCode.USER_NOT_FOUND));

        // 한 페이지당 10개씩, 최대 10페이지(100개)까지 조회
        Pageable pageable = PageRequest.of(page, 10);

        return restaurantRepository.findNearbyRestaurants(latitude, longitude, radius, pageable)
                .getContent()
                .stream()
                .map(restaurant -> {
                    ResponseRestaurant response = new ResponseRestaurant();
                    response.setRestaurantId(restaurant.getRestaurantId());
                    response.setName(restaurant.getNaverInformation().getName());
                    response.setCategory(restaurant.getNaverInformation().getCategory());
                    response.setLatitude(restaurant.getNaverInformation().getLatitude());
                    response.setLongitude(restaurant.getNaverInformation().getLongitude());
                    response.setThumbnailUrl(restaurant.getNaverInformation().getThumbnailUrl());
                    response.setFullAddress(restaurant.getOpenDataInformation().getFullAddress());
                    response.setRoadNameFullAddress(restaurant.getOpenDataInformation().getRoadNameFullAddress());
                    response.setPhoneNumber(restaurant.getOpenDataInformation().getContactNumber());
                    response.setTodayOpening(restaurant.getNaverInformation().getTodayOperatingHours());

                    // top2Features 설정
                    List<String> top2Features = naverReviewFeatureCountRepository
                            .findTop2ByRestaurantIdOrderByReviewCountDesc(restaurant.getRestaurantId())
                            .stream()
                            .map(c -> c.getNaverReviewFeature().getFeature())
                            .toList();
                    response.setTop2Features(top2Features);

                    response.setScrapped(userRestaurantScrapRepository.existsByUserIdAndRestaurantId(userId, restaurant.getRestaurantId()));
                    response.setLikeCount(Long.valueOf(userRestaurantVoteRepository.countByRestaurantIdAndVoteType(restaurant.getRestaurantId(), VoteType.LIKE)));
                    response.setDislikeCount(Long.valueOf(userRestaurantVoteRepository.countByRestaurantIdAndVoteType(restaurant.getRestaurantId(), VoteType.DISLIKE)));
                    return response;
                })
                .collect(Collectors.toList());
    }

    @Transactional
    public VoteResponse vote(String userId, String restaurantId, VoteType voteType) {
        // 사용자 존재 여부 확인
        userRepository.findByUserId(userId)
                .orElseThrow(() -> new VoteException(VoteErrorCode.USER_NOT_FOUND));

        // 식당 존재 여부 확인
        restaurantRepository.findByRestaurantId(restaurantId)
                .orElseThrow(() -> new VoteException(VoteErrorCode.RESTAURANT_NOT_FOUND));

        // 투표 타입 유효성 검사
        if (voteType == null) {
            throw new VoteException(VoteErrorCode.INVALID_VOTE_TYPE);
        }

        Optional<UserRestaurantVote> existingVote = userRestaurantVoteRepository
                .findByUserIdAndRestaurantId(userId, restaurantId);

        if (existingVote.isPresent()) {
            UserRestaurantVote vote = existingVote.get();
            if (vote.getVoteType() == voteType) {
                userRestaurantVoteRepository.delete(vote);
                return createVoteResponse("Vote removed", restaurantId);
            } else {
                vote.updateVote(voteType);
                return createVoteResponse("Vote updated", restaurantId);
            }
        } else {
            UserRestaurantVote newVote = UserRestaurantVote.builder()
                    .userId(userId)
                    .restaurantId(restaurantId)
                    .voteType(voteType)
                    .build();
            userRestaurantVoteRepository.save(newVote);
            return createVoteResponse("Vote added", restaurantId);
        }
    }

    private VoteResponse createVoteResponse(String message, String restaurantId) {
        return VoteResponse.builder()
                .message(message)
                .likes(userRestaurantVoteRepository.countByRestaurantIdAndVoteType(restaurantId, VoteType.LIKE))
                .dislikes(userRestaurantVoteRepository.countByRestaurantIdAndVoteType(restaurantId, VoteType.DISLIKE))
                .build();
    }
}