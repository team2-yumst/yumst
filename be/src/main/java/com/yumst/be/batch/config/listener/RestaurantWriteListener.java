package com.yumst.be.batch.config.listener;

import com.yumst.be.batch.domain.FailedRecord;
import com.yumst.be.batch.repository.FailedRecordRepository;
import com.yumst.be.restaurant.domain.Restaurant;
import lombok.RequiredArgsConstructor;
import org.springframework.batch.core.ItemWriteListener;
import org.springframework.batch.item.Chunk;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import static org.springframework.transaction.annotation.Propagation.REQUIRES_NEW;

@Component
@RequiredArgsConstructor
public class RestaurantWriteListener implements ItemWriteListener<Restaurant> {

    private final FailedRecordRepository failedRecordRepository;


    @Transactional(propagation = REQUIRES_NEW)
    @Override
    public void onWriteError(Exception exception, Chunk<? extends Restaurant> items) {

        items.getItems().forEach(item -> {
            FailedRecord failedRecord = FailedRecord.builder()
                    .recordType("WRITE")
                    .recordDataId(item.getRestaurantId())
                    .errorMessage(exception.getMessage())
                    .build();

            failedRecordRepository.save(failedRecord);
        });
    }
}
