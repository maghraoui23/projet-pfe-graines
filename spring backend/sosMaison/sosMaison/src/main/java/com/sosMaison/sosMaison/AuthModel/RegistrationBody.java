package com.sosMaison.sosMaison.AuthModel;

import jakarta.validation.constraints.*;
import lombok.Getter;

@Getter
public class RegistrationBody {

    @Pattern(regexp = "^\\+?[0-9\\-\\s]{8,15}$")
    private String phoneNumber;


    /** The username. */
    @NotNull
    @NotBlank
    @Size(min=5, max=255)
    private String username;
    /** The email. */
    @NotNull
    @NotBlank
    @Email
    private String email;
    /** The password. */
    @NotNull
    @NotBlank
    @Pattern(regexp = "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d]{6,}$")
    @Size(min=6, max=50)
    private String password;
    /** The first name. */
    @NotNull
    @NotBlank
    private String firstName;
    /** The last name. */
    @NotNull
    @NotBlank
    private String lastName;

    public RegistrationBody(String username, String email, String password, String firstName, String lastName,String phonenumber) {
        this.username = username;
        this.email = email;
        this.password = password;
        this.firstName = firstName;
        this.lastName = lastName;
        this.phoneNumber = phonenumber;
    }

    public @NotNull @NotBlank @Size(min = 5, max = 255) String getUsername() {
        return username;
    }

    public @NotNull @NotBlank @Email String getEmail() {
        return email;
    }

    public @NotNull @NotBlank @Pattern(regexp = "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d]{6,}$") @Size(min = 6, max = 32) String getPassword() {
        return password;
    }

    public @NotNull @NotBlank String getFirstName() {
        return firstName;
    }

    public @NotNull @NotBlank String getLastName() {
        return lastName;
    }

    public @Pattern(regexp = "^\\+?[0-9\\-\\s]{8,15}$") String getPhoneNumber() {
        return phoneNumber;
    }
}
