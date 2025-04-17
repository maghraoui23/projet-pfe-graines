package com.sosMaison.sosMaison.AuthModel;


import jakarta.validation.constraints.*;

public class ProfessionalLoginBody {
    @Pattern(regexp = "^\\+?[0-9\\-\\s]{8,15}$")
    @NotBlank
    private String phoneNumber;

    @NotBlank
    @Size(min=8)
    private String password;

    public ProfessionalLoginBody(String phoneNumber, String password) {
        this.phoneNumber = phoneNumber;
        this.password = password;
    }

    public @Pattern(regexp = "^\\+?[0-9\\-\\s]{8,15}$") @NotBlank String getPhoneNumber() {
        return phoneNumber;
    }

    public @NotBlank @Size(min = 8) String getPassword() {
        return password;
    }
    // getters/setters
}

