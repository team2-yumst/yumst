package com.yumst.be.batch.config.listener;

import com.yumst.be.batch.domain.FailedRecord;
import com.yumst.be.batch.repository.FailedRecordRepository;
import com.yumst.be.restaurant.domain.Restaurant;
import lombok.RequiredArgsConstructor;
import org.springframework.batch.core.ItemProcessListener;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import static org.springframework.transaction.annotation.Propagation.REQUIRES_NEW;

@Component
@RequiredArgsConstructor
public class RestaurantProcessListener implements ItemProcessListener<Restaurant, Restaurant> {

    private final FailedRecordRepository failedRecordRepository;


    @Transactional(propagation = REQUIRES_NEW)
    @Override
    public void onProcessError(Restaurant item, Exception e) {

        if (e.getMessage().length() > 1024) {
            e = new Exception(e.getMessage().substring(0, 1024));
        }

        FailedRecord failedRecord = FailedRecord.builder()
                .recordType("PROCESS")
                .recordDataId(item.getRestaurantId())
                .errorMessage(e.getMessage())
                .build();

        failedRecordRepository.save(failedRecord);
    }
}
