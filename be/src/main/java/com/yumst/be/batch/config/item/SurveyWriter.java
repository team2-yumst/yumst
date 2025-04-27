package com.yumst.be.batch.config.item;

import com.yumst.be.batch.dto.SurveyCompositeData;
import com.yumst.be.user.repository.UserPreferenceRepository;
import com.yumst.be.user.repository.UserRepository;
import com.yumst.be.vote.repository.UserRestaurantVoteRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.batch.item.Chunk;
import org.springframework.batch.item.ItemWriter;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

@Component
@RequiredArgsConstructor
public class SurveyWriter implements ItemWriter<SurveyCompositeData> {

    private final UserRepository userRepository;
    private final UserPreferenceRepository userPreferenceRepository;
    private final UserRestaurantVoteRepository userRestaurantVoteRepository;

    @Override
    @Transactional
    public void write(Chunk<? extends SurveyCompositeData> chunk) throws Exception {



    }
}
