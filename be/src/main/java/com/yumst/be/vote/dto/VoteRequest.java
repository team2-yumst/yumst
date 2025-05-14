package com.yumst.be.vote.dto;

import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import com.yumst.be.vote.domain.VoteType;

@Getter
public class VoteRequest {
    @NotNull(message = "투표 타입은 필수입니다.")
    private VoteType voteType;
} 