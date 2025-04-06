package com.yumst.be.vote.dto;

import jakarta.validation.constraints.NotNull;
import lombok.Getter;

@Getter
public class VoteRequest {
    @NotNull(message = "투표 타입은 필수입니다.")
    private VoteType voteType;
} 