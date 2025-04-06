package com.yumst.be.vote.dto;

import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class VoteResponse {
    private String message;
    private Long likes;
    private Long dislikes;
} 