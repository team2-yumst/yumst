package com.yumst.be.vote.service;

import com.yumst.be.restaurant.service.RestaurantService;
import com.yumst.be.restaurant.vo.ResponseRestaurant;
import com.yumst.be.user.service.UserService;
import com.yumst.be.vote.domain.UserRestaurantVote;
import com.yumst.be.vote.dto.RestaurantRequest;
import com.yumst.be.vote.dto.VoteResponse;
import com.yumst.be.vote.domain.VoteType;
import com.yumst.be.vote.exception.VoteErrorCode;
import com.yumst.be.vote.exception.VoteException;
import com.yumst.be.vote.repository.UserRestaurantVoteRepository;
import com.yumst.be.vote.util.VoteRateLimiter;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.orm.ObjectOptimisticLockingFailureException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class UserRestaurantVoteService {
    private final UserRestaurantVoteRepository userRestaurantVoteRepository;
    private final RestaurantService restaurantService;
    private final UserService userService;
    private final VoteRateLimiter voteRateLimiter;

    @Transactional(readOnly = true)
    public List<ResponseRestaurant> getVotableRestaurants(String userId, RestaurantRequest request) {
        userService.validateUserExists(userId);

        Double latitude = request.getLatitude();
        Double longitude = request.getLongitude();
        Double radius = request.getRadius();
        String sort = (request.getSort() != null && !request.getSort().isEmpty()) ? request.getSort() : "distance";
        int page = (request.getPage() != null && request.getPage() >= 0) ? request.getPage() : 0;

        Pageable pageable = PageRequest.of(page, 10);

        return restaurantService.findNearbyRestaurants(userId, latitude, longitude, radius, sort, pageable);
    }

    @Transactional
    public VoteResponse vote(String userId, String restaurantId, VoteType voteType) {
        // 요청 레이트 체크
        if (!voteRateLimiter.allowRequest(userId)) {
            throw new VoteException(VoteErrorCode.TOO_MANY_REQUESTS);
        }

        try {
            // 사용자 존재 여부 확인
            userService.validateUserExists(userId);

            // 식당 존재 여부 확인
            restaurantService.validateRestaurantExists(restaurantId);

            Optional<UserRestaurantVote> existingVote = userRestaurantVoteRepository
                    .findByUserIdAndRestaurantId(userId, restaurantId);

            // voteType이 null인 경우 투표 취소 처리
            if (voteType == null) {
                if (existingVote.isPresent()) {
                    userRestaurantVoteRepository.delete(existingVote.get());
                    return createVoteResponse("Vote removed", restaurantId);
                }
                return createVoteResponse("No vote to remove", restaurantId);
            }

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
        } catch (ObjectOptimisticLockingFailureException e) {
            // 낙관적 락 실패 시 재시도 로직
            return vote(userId, restaurantId, voteType);
        }
    }

    private VoteResponse createVoteResponse(String message, String restaurantId) {
        Integer likes = userRestaurantVoteRepository.countByRestaurantIdAndVoteType(restaurantId, VoteType.LIKE);
        Integer dislikes = userRestaurantVoteRepository.countByRestaurantIdAndVoteType(restaurantId, VoteType.DISLIKE);
        
        return VoteResponse.builder()
                .message(message)
                .restaurantId(restaurantId)
                .likes(likes.longValue())
                .dislikes(dislikes.longValue())
                .build();
    }
}