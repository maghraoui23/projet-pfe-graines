package com.sosMaison.sosMaison.Publication;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.sosMaison.sosMaison.Commentaire.Commentaire;
import com.sosMaison.sosMaison.User.User;
import com.sosMaison.sosMaison.likes.LikeEntity;
import jakarta.persistence.*;
import lombok.*;


import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;


@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor

public class Publication {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String contenu;
    private String image;

    @ManyToOne
    private User auteur;

    private LocalDateTime datePublication = LocalDateTime.now();
    private int likes = 0; // Compteur de likes

    @OneToMany(mappedBy = "publication", cascade = CascadeType.ALL, orphanRemoval = true)
    @JsonIgnore  // Ignore la sérialisation de la relation Commentaire dans Publication
    private List<Commentaire> commentaires = new ArrayList<>();

    @OneToMany(mappedBy = "publication", cascade = CascadeType.ALL, orphanRemoval = true)
    @JsonIgnore
    private List<LikeEntity> List_Likes = new ArrayList<>();


    // Méthodes pour gérer les likes
    public void addLike() {
        this.likes++;
    }

    public void removeLike() {
        if (this.likes > 0) {
            this.likes--;
        }
    }




    public Long getId() {
        return id;
    }

    public String getContenu() {
        return contenu;
    }

    public String getImage() {
        return image;
    }

    public User getAuteur() {
        return auteur;
    }

    public LocalDateTime getDatePublication() {
        return datePublication;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public void setContenu(String contenu) {
        this.contenu = contenu;
    }

    public void setImage(String image) {
        this.image = image;
    }

    public void setAuteur(User auteur) {
        this.auteur = auteur;
    }

    public void setDatePublication(LocalDateTime datePublication) {
        this.datePublication = datePublication;
    }

    public int getLikes() {
        return likes;
    }

    public void setLikes(int likes) {
        this.likes = likes;
    }


    public List<Commentaire> getCommentaires() {
        return commentaires;
    }

    public void setCommentaires(List<Commentaire> commentaires) {
        this.commentaires = commentaires;
    }

    public List<LikeEntity> getList_Likes() {
        return List_Likes;
    }

    public void setList_Likes(List<LikeEntity> list_Likes) {
        List_Likes = list_Likes;
    }
}
