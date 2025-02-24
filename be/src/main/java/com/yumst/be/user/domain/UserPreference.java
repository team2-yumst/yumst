package com.yumst.be.user.domain;

import com.yumst.be.global.entity.BaseTimeEntity;
import jakarta.persistence.*;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import static jakarta.persistence.FetchType.*;
import static jakarta.persistence.GenerationType.IDENTITY;
import static lombok.AccessLevel.PROTECTED;

@Entity
@Table(name = "user_preference")
@NoArgsConstructor(access = PROTECTED)
@Getter
public class UserPreference extends BaseTimeEntity {

    @Id @GeneratedValue(strategy = IDENTITY)
    private Long id;

    @JoinColumn(name = "user_id", referencedColumnName = "id")
    @ManyToOne(fetch = LAZY)
    private UserEntity user;

    private String preference;

    @Builder
    public UserPreference(UserEntity user, String preference) {
        this.user = user;
        this.preference = preference;
    }
}
