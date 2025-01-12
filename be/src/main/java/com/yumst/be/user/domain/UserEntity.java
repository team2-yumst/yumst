package com.yumst.be.user.domain;

import com.yumst.be.global.entity.BaseTimeEntity;
import jakarta.persistence.*;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.util.UUID;

import static jakarta.persistence.EnumType.STRING;
import static jakarta.persistence.GenerationType.IDENTITY;
import static lombok.AccessLevel.PROTECTED;

@Entity
@Table(name = "users")
@NoArgsConstructor(access = PROTECTED)
@Getter
public class UserEntity extends BaseTimeEntity {

    @Id @GeneratedValue(strategy = IDENTITY)
    private Long id;

    @Column(unique = true, nullable = false)
    private String userId;

    @Column(nullable = false, length = 50)
    private String name;

    @Column(unique = true, nullable = false, length = 50)
    private String email;

    @Enumerated(STRING)
    private Gender gender;
    @Enumerated(STRING)
    private AgeRange ageRange;
    @Enumerated(STRING)
    private Tendency tendency;

    @Enumerated(STRING)
    @Column(nullable = false)
    private Role role;

    // OAuth 회원가입
    @Builder
    public UserEntity(String email, String name) {
        this.userId = UUID.randomUUID().toString();
        this.role = Role.USER;
        this.name = name;
        this.email = email;
    }

    // 회원가입 추가로직
    public UserEntity updateRegister(Gender gender, AgeRange ageRange, Tendency tendency) {
        this.gender = gender;
        this.ageRange = ageRange;
        this.tendency = tendency;
        return this;
    }

}
