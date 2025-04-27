package com.yumst.be.vote.dto;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.util.List;

@Getter
@NoArgsConstructor
public class BatchVoteRequest {
    
    @NotEmpty(message = "투표 요청은 최소 1개 이상이어야 합니다.")
    @Size(max = 20, message = "한 번에 최대 20개까지 투표 요청을 처리할 수 있습니다.")
    private List<@Valid SingleVoteRequest> votes;
    
    @Getter
    @NoArgsConstructor
    public static class SingleVoteRequest {
        @NotNull(message = "레스토랑 ID는 필수입니다.")
        private String restaurantId;
        
        @NotNull(message = "투표 타입은 필수입니다.")
        private VoteType voteType;
    }
} 