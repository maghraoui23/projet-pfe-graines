package com.sosMaison.sosMaison.AuthModel;

import jakarta.validation.constraints.*;
public class AdminLoginBody {
    @Email
    @NotBlank
    private String email;

    @NotBlank
    @Size(min=8)
    private String password;

    public AdminLoginBody(String email, String password) {
        this.email = email;
        this.password = password;
    }

    public @Email @NotBlank String getEmail() {
        return email;
    }

    public @NotBlank @Size(min = 8) String getPassword() {
        return password;
    }
    // getters/setters
}