package com.sosMaison.sosMaison.Professional;


import com.fasterxml.jackson.annotation.JsonBackReference;
import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonManagedReference;
import com.sosMaison.sosMaison.Evaluation.Evaluation;
import com.sosMaison.sosMaison.Localisation.Localisation;
import com.sosMaison.sosMaison.Services.Service;
import com.sosMaison.sosMaison.User.Role;
import com.sosMaison.sosMaison.User.User;
import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;
import java.util.Comparator;
import java.util.List;
import java.util.Optional;

@Entity
@Data

public class Professional extends User {
    @ManyToOne
    @JoinColumn(name = "service_id")
    @JsonBackReference
    private Service service;

    private String experience;
    private double prix_service;

    @ElementCollection
    private List<String> diplomes;


    @OneToMany(mappedBy = "professional", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    @JsonIgnore
    private List<Evaluation> evaluations;

    public Professional(Long id, String nom, String email, String password, String phoneNummber, Role role, Localisation localisation, LocalDateTime dateCreation, List<Service> services, String experience, List<String> diplomes, double moyenneAvis) {
        super(id, nom, email, password, phoneNummber, role, localisation, dateCreation);
        this.service = service;
        this.experience = experience;
        this.diplomes = diplomes;

    }

    public Professional(List<Service> services, String experience, List<String> diplomes, double moyenneAvis) {
        this.service = service;
        this.experience = experience;
        this.diplomes = diplomes;

    }

    public Professional() {

    }

    public Service getService() {
        return service;
    }

    public String getExperience() {
        return experience;
    }

    public List<String> getDiplomes() {
        return diplomes;
    }


    public double getMoyenneAvis() {
        if (evaluations == null || evaluations.isEmpty()) {
            return 0.0;
        }
        return evaluations.stream().mapToInt(Evaluation::getRating).average().orElse(0.0);
    }

    public void setService(Service service) {
        this.service = service;
    }

    public void setExperience(String experience) {
        this.experience = experience;
    }

    public void setDiplomes(List<String> diplomes) {
        this.diplomes = diplomes;
    }




    public double getPrix_service() {
        return prix_service;
    }

    public void setPrix_service(double prix_service) {
        this.prix_service = prix_service;
    }
    @Transient
    public int getNombreEvaluations() {
        return evaluations != null ? evaluations.size() : 0;
    }

    @Transient
    public int getHighestRating() {
        if (evaluations == null || evaluations.isEmpty()) {
            return 0;
        }
        return evaluations.stream()
                .mapToInt(Evaluation::getRating)
                .max()
                .orElse(0);
    }

    @Transient
    public String getHighestComment() {
        if (evaluations == null || evaluations.isEmpty()) {
            return null;
        }
        Optional<Evaluation> highest = evaluations.stream()
                .max(Comparator.comparingInt(Evaluation::getRating));
        return highest.map(Evaluation::getComment).orElse(null);
    }
}
