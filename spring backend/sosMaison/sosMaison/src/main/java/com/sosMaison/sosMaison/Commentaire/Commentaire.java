package com.sosMaison.sosMaison.Commentaire;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.sosMaison.sosMaison.Publication.Publication;
import com.sosMaison.sosMaison.User.User;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Commentaire {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String contenu;
    @ManyToOne
    private Publication publication; // Ajout de la relation avec Publication

    @ManyToOne
    private User auteur; // L'auteur du commentaire

    private LocalDateTime dateCommentaire = LocalDateTime.now();

    public Long getId() {
        return id;
    }

    public String getContenu() {
        return contenu;
    }

    public User getAuteur() {
        return auteur;
    }

    public LocalDateTime getDateCommentaire() {
        return dateCommentaire;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public void setContenu(String contenu) {
        this.contenu = contenu;
    }

    public void setDateCommentaire(LocalDateTime dateCommentaire) {
        this.dateCommentaire = dateCommentaire;
    }

    public void setAuteur(User auteur) {
        this.auteur = auteur;
    }

    public Publication getPublication() {
        return publication;
    }

    public void setPublication(Publication publication) {
        this.publication = publication;
    }
}
