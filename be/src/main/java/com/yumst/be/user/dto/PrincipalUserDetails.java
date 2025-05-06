package com.yumst.be.user.dto;

import com.yumst.be.user.domain.UserEntity;
import lombok.Data;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.oauth2.core.user.OAuth2User;

import java.util.Collection;
import java.util.List;
import java.util.Map;

@Data
public class PrincipalUserDetails implements OAuth2User, UserDetails {

    private final UserEntity userEntity;
    private final Map<String, Object> attributes;


    @Override
    public String getUsername() {
        return userEntity.getEmail();
    }

    @Override
    public Map<String, Object> getAttributes() {
        return attributes;
    }

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        String roleValue = userEntity.getRole().getValue();
        return List.of(new SimpleGrantedAuthority(roleValue));
    }

    @Override
    public String getPassword() {
        return "";
    }

    @Override
    public String getName() {
        return "";
    }

    @Override
    public boolean isAccountNonExpired() {
        return true;
    }

    @Override
    public boolean isAccountNonLocked() {
        return true;
    }

    @Override
    public boolean isCredentialsNonExpired() {
        return true;
    }

    @Override
    public boolean isEnabled() {
        return true;
    }
}
