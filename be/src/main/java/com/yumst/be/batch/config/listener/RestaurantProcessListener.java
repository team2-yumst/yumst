package com.yumst.be.batch.config.listener;

import com.yumst.be.batch.domain.FailedRecord;
import com.yumst.be.batch.repository.FailedRecordRepository;
import com.yumst.be.restaurant.domain.Restaurant;
import lombok.RequiredArgsConstructor;
import org.springframework.batch.core.ItemProcessListener;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class RestaurantProcessListener implements ItemProcessListener<Restaurant, Restaurant> {

    private final FailedRecordRepository failedRecordRepository;


    @Override
    public void onProcessError(Restaurant item, Exception e) {

        FailedRecord failedRecord = FailedRecord.builder()
                .recordType("PROCESS")
                .recordDataId(item.getRestaurantId())
                .errorMessage(e.getMessage())
                .build();

        failedRecordRepository.save(failedRecord);
    }
}
