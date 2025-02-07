package com.yumst.be.user.domain;

import com.yumst.be.global.entity.BaseTimeEntity;
import jakarta.persistence.*;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.ColumnDefault;

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

    @Column(length = 1024)
    private String imageUrl;

    @ColumnDefault("false")
    private boolean isGuest;

    @Enumerated(STRING)
    @Column(nullable = false)
    private Role role;

    @Column(nullable = false)
    private boolean isDeleted;

    // OAuth 회원가입
    @Builder
    public UserEntity(String email, String name, String imageUrl) {
        this.userId = UUID.randomUUID().toString();
        this.role = Role.USER;
        this.isDeleted = false;

        this.name = name;
        this.email = email;
        this.imageUrl = imageUrl;
    }

    public UserEntity registerGuest() {
        this.userId = UUID.randomUUID().toString();
        this.name = "guest";
        this.email = userId + "@guest.com";
        this.imageUrl = "https://img.icons8.com/fluency-systems-filled/96/guest-male.png";
        this.role = Role.USER;
        this.isDeleted = false;
        this.isGuest = true;

        return this;
    }


}
