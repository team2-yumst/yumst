package com.yumst.be.batch.dto;

import com.yumst.be.user.domain.UserEntity;
import com.yumst.be.user.domain.UserPreference;
import com.yumst.be.vote.domain.UserRestaurantVote;
import lombok.Builder;
import lombok.Data;

import java.util.List;

@Data
public class SurveyCompositeData {
    UserEntity userEntity;
    List<UserPreference> preferences;
    List<UserRestaurantVote> votes;

    @Builder
    public SurveyCompositeData(UserEntity userEntity, List<UserPreference> preferences, List<UserRestaurantVote> votes) {
        this.userEntity = userEntity;
        this.preferences = preferences;
        this.votes = votes;
    }
}
