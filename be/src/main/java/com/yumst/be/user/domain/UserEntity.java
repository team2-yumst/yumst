package com.yumst.be.user.domain;

import com.yumst.be.global.entity.BaseTimeEntity;
import jakarta.persistence.*;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.ColumnDefault;
import org.hibernate.annotations.SQLDelete;
import org.hibernate.annotations.SQLRestriction;

import java.util.UUID;

import static jakarta.persistence.EnumType.STRING;
import static jakarta.persistence.GenerationType.IDENTITY;
import static lombok.AccessLevel.PROTECTED;

@Entity
@Table(name = "users")
@NoArgsConstructor(access = PROTECTED)
@Getter
@SQLDelete(sql = "UPDATE users SET is_deleted = true WHERE id = ?")
@SQLRestriction("is_deleted = false")
public class UserEntity extends BaseTimeEntity {

    @Id @GeneratedValue(strategy = IDENTITY)
    private Long id;

    @Column(unique = true, nullable = false)
    private String userId;

    @Column(nullable = false, length = 50)
    private String name;

    @Column(unique = true, nullable = false, length = 50)
    private String email;

    @Column(length = 1024)
    private String imageUrl;

    @ColumnDefault("false")
    private boolean isGuest;

    @Enumerated(STRING)
    @Column(nullable = false)
    private Role role;

    @Column(nullable = false)
    private boolean isDeleted;

    @ColumnDefault("false")
    private boolean isEnabled;

    @Embedded
    private UserTerms userTerms;

    // OAuth 회원가입
    @Builder
    public UserEntity(String email, String name, String imageUrl) {
        this.userId = UUID.randomUUID().toString();
        this.role = Role.USER;
        this.isDeleted = false;
        this.userTerms = new UserTerms();

        this.name = name;
        this.email = email;
        this.imageUrl = imageUrl;
    }

    public static UserEntity createAppleUser(String email, String name, String userId) {
        UserEntity build = UserEntity.builder()
                .email(email)
                .name(name)
                .imageUrl("https://img.icons8.com/fluency-systems-filled/96/guest-male.png")
                .build();
        build.userId = userId;

        return build;
    }

    public UserEntity registerGuest() {
        this.name = "guest";
        this.email = userId + "@guest.com";
        this.imageUrl = "https://img.icons8.com/fluency-systems-filled/96/guest-male.png";
        this.isGuest = true;

        return this;
    }

    public void finishRegisterAndEnable() {
        this.isEnabled = true;
    }

    public void finishedSurvey() {
        this.userTerms.finishSurvey();
    }

    public void updateAgreeTerms() {
        this.userTerms.agreeTermsOfService();
        this.userTerms.agreePrivacyPolicy();
        this.userTerms.agreeLocationTerms();
    }


}
