package com.yumst.be.batch.domain;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.Id;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

import static jakarta.persistence.GenerationType.IDENTITY;

@Entity
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class FailedRecord {

    @Id
    @GeneratedValue(strategy = IDENTITY)
    private Long id;

    private String recordType;  // "READ", "PROCESS", "WRITE", "ROLLBACK"

    private String recordDataId;

    private String errorMessage;

    private LocalDateTime failedAt;


    @Builder
    public FailedRecord(String recordType, String recordDataId, String errorMessage) {
        this.failedAt = LocalDateTime.now();

        this.recordType = recordType;
        this.recordDataId = recordDataId;
        this.errorMessage = errorMessage;
    }
}
