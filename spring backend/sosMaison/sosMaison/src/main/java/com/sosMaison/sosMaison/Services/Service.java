package com.sosMaison.sosMaison.Services;

import com.fasterxml.jackson.annotation.JsonManagedReference;
import com.sosMaison.sosMaison.Localisation.Localisation;
import com.sosMaison.sosMaison.Professional.Professional;
import jakarta.persistence.*;
import lombok.*;

import java.util.*;
@Setter
@Getter
@Entity
@Data



public class Service {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String nom;
    private String description;
    private String categorie;

    @OneToMany(mappedBy = "service")
    @JsonManagedReference
    private List<Professional> professionnels;

   private String service_photo;

    public Service(Long id, String nom, String description, String categorie, List<Professional> professionnels, String service_photo) {
        this.id = id;
        this.nom = nom;
        this.description = description;
        this.categorie = categorie;
        this.professionnels = professionnels;
        this.service_photo = service_photo;
    }

    public Service() {
    }

    public Long getId() {
        return id;
    }

    public String getNom() {
        return nom;
    }

    public String getDescription() {
        return description;
    }

    public String getCategorie() {
        return categorie;
    }

    public List<Professional> getProfessionnels() {
        return professionnels;
    }

    public String getService_photo() {
        return service_photo;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public void setNom(String nom) {
        this.nom = nom;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public void setCategorie(String categorie) {
        this.categorie = categorie;
    }

    public void setProfessionnels(List<Professional> professionnels) {
        this.professionnels = professionnels;
    }

    public void setService_photo(String service_photo) {
        this.service_photo = service_photo;
    }
}
