package com.yumst.be.vote.service;

import com.yumst.be.restaurant.service.RestaurantService;
import com.yumst.be.restaurant.vo.ResponseRestaurant;
import com.yumst.be.user.service.UserService;
import com.yumst.be.vote.domain.UserRestaurantVote;
import com.yumst.be.vote.dto.BatchVoteRequest;
import com.yumst.be.vote.dto.RestaurantRequest;
import com.yumst.be.vote.dto.VoteResponse;
import com.yumst.be.vote.dto.VoteType;
import com.yumst.be.vote.exception.VoteErrorCode;
import com.yumst.be.vote.exception.VoteException;
import com.yumst.be.vote.repository.UserRestaurantVoteRepository;
import com.yumst.be.vote.util.VoteRateLimiter;
import com.yumst.be.restaurant.exception.RestaurantException;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.orm.ObjectOptimisticLockingFailureException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

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

    @Transactional
    public List<VoteResponse> batchVote(String userId, List<BatchVoteRequest.SingleVoteRequest> requests) {
        // 요청 레이트 체크
        if (!voteRateLimiter.allowRequest(userId)) {
            throw new VoteException(VoteErrorCode.TOO_MANY_REQUESTS);
        }

        // 배치 요청 개수 검증 (컨트롤러에서도 @Valid로 검증되지만 추가 검증)
        if (requests.size() > 20) {
            throw new VoteException(VoteErrorCode.BATCH_SIZE_EXCEEDED);
        }

        // 사용자 존재 여부 확인 (한 번만 검증)
        userService.validateUserExists(userId);

        List<VoteResponse> responses = new ArrayList<>();
        
        // 각 요청에 대해 투표 처리
        for (BatchVoteRequest.SingleVoteRequest request : requests) {
            String restaurantId = request.getRestaurantId();
            VoteType requestedVoteType = request.getVoteType();
            String message;
            
            try {
                // 식당 존재 여부 확인
                restaurantService.validateRestaurantExists(restaurantId);
                
                // 투표 처리
                Optional<UserRestaurantVote> existingVoteOpt = userRestaurantVoteRepository
                        .findByUserIdAndRestaurantId(userId, restaurantId);

                if (requestedVoteType == null) {
                    // 요청된 타입이 null (투표 취소)
                    if (existingVoteOpt.isPresent()) {
                        userRestaurantVoteRepository.delete(existingVoteOpt.get());
                        message = "Vote removed";
                    } else {
                        message = "Vote already absent"; // 이미 투표가 없는 상태
                    }
                } else {
                    // 요청된 타입이 null이 아님 (LIKE 또는 DISLIKE)
                    if (existingVoteOpt.isPresent()) {
                        UserRestaurantVote vote = existingVoteOpt.get();
                        if (vote.getVoteType() == requestedVoteType) {
                            message = "Vote unchanged"; // 이미 같은 타입으로 투표됨
                        } else {
                            vote.updateVote(requestedVoteType);
                            message = "Vote updated";
                        }
                    } else {
                        UserRestaurantVote newVote = UserRestaurantVote.builder()
                                .userId(userId)
                                .restaurantId(restaurantId)
                                .voteType(requestedVoteType)
                                .build();
                        userRestaurantVoteRepository.save(newVote);
                        message = "Vote added";
                    }
                }
                
                // 응답 생성
                responses.add(createVoteResponse(message, restaurantId));
            } catch (Exception e) {
                // 개별 요청 실패는 전체 배치를 실패시키지 않음
                // 대신 에러 메시지를 반환
                VoteResponse errorResponse = VoteResponse.builder()
                        .message("Error processing vote: " + e.getMessage()) // 에러 메시지 개선
                        .restaurantId(restaurantId)
                        .likes(0L) // 에러 시 카운트는 0으로 반환
                        .dislikes(0L)
                        .build();
                responses.add(errorResponse);
            }
        }
        
        return responses;
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