package com.yumst.be.batch.repository;

import com.yumst.be.batch.domain.FailedRecord;
import org.springframework.data.jpa.repository.JpaRepository;

public interface FailedRecordRepository extends JpaRepository<FailedRecord, Long> {
}
