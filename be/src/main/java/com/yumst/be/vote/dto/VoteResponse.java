package com.yumst.be.vote.dto;

import lombok.Getter;
import lombok.Setter;
import lombok.Builder;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class VoteResponse {
    private String message;
    private Integer likes;
    private Integer dislikes;
} 