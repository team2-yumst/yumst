package com.yumst.be.user.domain;

import jakarta.persistence.Embeddable;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.ColumnDefault;

import java.time.LocalDateTime;

@Embeddable
@NoArgsConstructor
@Getter
public class UserTerms {

    @ColumnDefault("false")
    private boolean finishedSurvey;

    @ColumnDefault("false")
    private boolean agreedPrivacyPolicy;
    private LocalDateTime agreedPrivacyPolicyAt;

    @ColumnDefault("false")
    private boolean agreedTermsOfService;
    private LocalDateTime agreedTermsOfServiceAt;

    @ColumnDefault("false")
    private boolean agreedLocationTerms;
    private LocalDateTime agreedLocationTermsAt;

    @ColumnDefault("false")
    private boolean agreedMarketing;
    private LocalDateTime agreedMarketingAt;


    public void finishSurvey() {
        this.finishedSurvey = true;
    }

    public void agreePrivacyPolicy() {
        this.agreedPrivacyPolicy = true;
        this.agreedPrivacyPolicyAt = LocalDateTime.now();
    }

    public void agreeTermsOfService() {
        this.agreedTermsOfService = true;
        this.agreedTermsOfServiceAt = LocalDateTime.now();
    }

    public void agreeLocationTerms() {
        this.agreedLocationTerms = true;
        this.agreedLocationTermsAt = LocalDateTime.now();
    }

    public void agreeMarketing() {
        this.agreedMarketing = true;
        this.agreedMarketingAt = LocalDateTime.now();
    }
}
