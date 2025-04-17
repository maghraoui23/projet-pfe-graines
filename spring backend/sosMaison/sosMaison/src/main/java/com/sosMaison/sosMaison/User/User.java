package com.sosMaison.sosMaison.User;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.sosMaison.sosMaison.Conversation.Conversation;
import com.sosMaison.sosMaison.Localisation.Localisation;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;
import java.util.List;

@Entity
@Inheritance(strategy = InheritanceType.JOINED)
@Data
@Table(name = "users", uniqueConstraints = {@UniqueConstraint(columnNames = "username"),@UniqueConstraint(columnNames = "email")})
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String FirstName;
    private String LastName;
    private String username;
    private String email;
    private String password;
    private String phoneNumber;
    private String Photo;

    @Enumerated(EnumType.STRING)
    private Role role;

    @OneToOne(cascade = CascadeType.ALL)
    private Localisation localisation;

    private LocalDateTime dateCreation = LocalDateTime.now();
    @Enumerated(EnumType.STRING)
    private AuthProvider provider; // LOCAL, GOOGLE, FACEBOOK

    private String providerId; // ID unique du provider

    public void setProviderId(String providerId) {
        this.providerId = providerId;
    }

    public enum AuthProvider {
        LOCAL, GOOGLE, FACEBOOK
    }

    @JsonIgnore
    @OneToMany(cascade = CascadeType.ALL, orphanRemoval = false,mappedBy = "auteur", fetch = FetchType.EAGER)
    private List<Conversation> conversationAuteur;

    @JsonIgnore
    @OneToMany(mappedBy = "recepteur",cascade = CascadeType.ALL, orphanRemoval = false, fetch = FetchType.EAGER)
    private List<Conversation> conversationRecepteur;

    public User(Long id, String nom, String email, String password, String phoneNummber, Role role, Localisation localisation, LocalDateTime dateCreation) {
        this.id = id;
        this.FirstName=FirstName;
        this.LastName=LastName;
        this.email = email;
        this.password = password;
        this.phoneNumber = phoneNummber;
        this.role = role;
        this.localisation = localisation;
        this.dateCreation = dateCreation;
        this.username=username;
    }

    public User() {
    }

    public Long getId() {
        return id;
    }



    public String getEmail() {
        return email;
    }

    public String getPassword() {
        return password;
    }

    public String getPhoneNummber() {
        return phoneNumber;
    }

    public Role getRole() {
        return role;
    }

    public Localisation getLocalisation() {
        return localisation;
    }

    public LocalDateTime getDateCreation() {
        return dateCreation;
    }

    public void setId(Long id) {
        this.id = id;
    }



    public void setEmail(String email) {
        this.email = email;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public void setPhoneNummber(String phoneNummber) {
        phoneNumber = phoneNummber;
    }

    public void setRole(Role role) {
        this.role = role;
    }

    public void setLocalisation(Localisation localisation) {
        this.localisation = localisation;
    }

    public void setDateCreation(LocalDateTime dateCreation) {
        this.dateCreation = dateCreation;
    }

    public String getFirstName() {
        return FirstName;
    }

    public String getLastName() {
        return LastName;
    }

    public void setFirstName(String firstName) {
        FirstName = firstName;
    }

    public void setLastName(String lastName) {
        LastName = lastName;
    }

    public String getPhoto() {
        return Photo;
    }

    public void setPhoto(String photo) {
        Photo = photo;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username.toLowerCase();
    }
    public void setProvider(AuthProvider provider) {
        this.provider = provider;
    }
}
