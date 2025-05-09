package com.yumst.be.user.vo.request;

public record RequestAppleAuth(
        String state,
        String authorizationCode,
        String idToken,
        User user
) {

    public record User(
            String email,
            Name name
    ){
    }

    public record Name(
            String firstName,
            String lastName
    ){
    }

}

