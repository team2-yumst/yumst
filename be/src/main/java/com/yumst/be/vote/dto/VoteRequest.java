package com.yumst.be.vote.dto;

import lombok.Getter;
import com.yumst.be.vote.domain.VoteType;

@Getter
public class VoteRequest {
    private VoteType voteType;
} 