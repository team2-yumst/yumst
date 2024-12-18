package com.yumst.be.user.domain;

import com.yumst.be.global.entity.BaseTimeEntity;
import jakarta.persistence.*;

import static jakarta.persistence.EnumType.STRING;
import static jakarta.persistence.GenerationType.*;

@Entity
@Table(name = "users")
public class UserEntity extends BaseTimeEntity {

    @Id @GeneratedValue(strategy = IDENTITY)
    private Long id;

    @Column(unique = true, nullable = false)
    private String userId;

    @Column(unique = true, nullable = false, length = 50)
    private String email;

    // TODO: 닉네임 자동 생성 기능 추가후 unique 제약조건 추가
    @Column(nullable = false, length = 30)
    private String nickName;

    // TODO: 기본 프로필 이미지 추가
    private String imageUrl;


    @Enumerated(STRING)
    private Gender gender;
    @Enumerated(STRING)
    private AgeRange ageRange;
    @Enumerated(STRING)
    private Role role;
    @Enumerated(STRING)
    private Tendency tendency;

    private double averageViewTime;
    private double likeRatio;

}
