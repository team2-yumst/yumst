package com.yumst.be.vote.service;

import com.yumst.be.restaurant.service.RestaurantService;
import com.yumst.be.restaurant.vo.ResponseRestaurant;
import com.yumst.be.user.service.UserService;
import com.yumst.be.vote.domain.UserRestaurantVote;
import com.yumst.be.vote.dto.RestaurantRequest;
import com.yumst.be.vote.dto.VoteResponse;
import com.yumst.be.vote.dto.VoteType;
import com.yumst.be.vote.repository.UserRestaurantVoteRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

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
        // 사용자 존재 여부 확인
        userService.validateUserExists(userId);

        // 식당 존재 여부 확인
        restaurantService.getResponseRestaurantList(List.of(restaurantId), userId);

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
                .likes(Long.valueOf(userRestaurantVoteRepository.countByRestaurantIdAndVoteType(restaurantId, VoteType.LIKE)))
                .dislikes(Long.valueOf(userRestaurantVoteRepository.countByRestaurantIdAndVoteType(restaurantId, VoteType.DISLIKE)))
                .build();
    }
}