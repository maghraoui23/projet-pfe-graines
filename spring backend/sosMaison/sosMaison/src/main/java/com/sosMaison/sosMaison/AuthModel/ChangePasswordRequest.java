package com.sosMaison.sosMaison.AuthModel;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public class ChangePasswordRequest {
    @NotBlank
    private String oldPassword;

    @NotBlank
    @Size(min = 8, message = "Le mot de passe doit contenir au moins 8 caractères")
    private String newPassword;

    public @NotBlank String getOldPassword() {
        return oldPassword;
    }

    public void setOldPassword(@NotBlank String oldPassword) {
        this.oldPassword = oldPassword;
    }

    public @NotBlank @Size(min = 8, message = "Le mot de passe doit contenir au moins 8 caractères") String getNewPassword() {
        return newPassword;
    }

    public void setNewPassword(@NotBlank @Size(min = 8, message = "Le mot de passe doit contenir au moins 8 caractères") String newPassword) {
        this.newPassword = newPassword;
    }

    // Getters/Setters
}