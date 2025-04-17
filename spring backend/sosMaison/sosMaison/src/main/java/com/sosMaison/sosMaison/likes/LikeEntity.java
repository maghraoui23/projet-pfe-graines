package com.sosMaison.sosMaison.likes;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.sosMaison.sosMaison.Publication.Publication;
import com.sosMaison.sosMaison.User.User;
import jakarta.persistence.Entity;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
public class LikeEntity {  // Renommé en LikeEntity pour éviter les conflits avec le mot-clé SQL "LIKE"
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    private User user;  // L'utilisateur qui a liké

    @ManyToOne
    @JsonIgnore
    private Publication publication;  // La publication likée

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }

    public Publication getPublication() {
        return publication;
    }

    public void setPublication(Publication publication) {
        this.publication = publication;
    }
}