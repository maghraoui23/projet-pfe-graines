package com.sosMaison.sosMaison.Evaluation;

import com.fasterxml.jackson.annotation.JsonBackReference;
import com.fasterxml.jackson.annotation.JsonIgnore;
import com.sosMaison.sosMaison.Professional.Professional;
import com.sosMaison.sosMaison.User.User;
import jakarta.persistence.Entity;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Getter
@Entity
@Data
@Table(name = "evaluations")
public class Evaluation {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @ManyToOne
    @JoinColumn(name = "professional_id", nullable = false)
    @JsonIgnore  // Évite la boucle infinie lors de la sérialisation
    private Professional professional;

    @Column(name = "rating")
    private int rating; // Note entre 1 et 5 étoiles
    private String comment; // Optionnel : commentaire de l'utilisateur
    private LocalDateTime dateEvaluation = LocalDateTime.now();

    public Evaluation(Long id, User user, Professional professional, int rating, String comment, LocalDateTime dateEvaluation) {
        this.id = id;
        this.user = user;
        this.professional = professional;
        this.rating = rating;
        this.comment = comment;
        this.dateEvaluation = dateEvaluation;
    }

    public Evaluation() {
    }


    public void setId(Long id) {
        this.id = id;
    }

    public void setUser(User user) {
        this.user = user;
    }

    public void setProfessional(Professional professional) {
        this.professional = professional;
    }

    public void setRating(int rating) {
        this.rating = rating;
    }

    public void setComment(String comment) {
        this.comment = comment;
    }

    public void setDateEvaluation(LocalDateTime dateEvaluation) {
        this.dateEvaluation = dateEvaluation;
    }

    public Long getId() {
        return id;
    }

    public User getUser() {
        return user;
    }

    public Professional getProfessional() {
        return professional;
    }

    public int getRating() {
        return rating;
    }

    public String getComment() {
        return comment;
    }

    public LocalDateTime getDateEvaluation() {
        return dateEvaluation;
    }
}