package com.sosMaison.sosMaison.Publication;

import org.springframework.beans.factory.annotation.*;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.*;

@RestController
@RequestMapping("/publications")
public class PublicationController {

    @Autowired
    private PublicationService publicationService;

    // Créer une nouvelle publication pour un utilisateur
    @PostMapping("/user/{userId}")
    public Publication createPublication(@PathVariable Long userId, @RequestBody Publication publication) {
        return publicationService.createPublication(userId, publication);
    }

    // Récupérer toutes les publications
    @GetMapping
    public List<Publication> getAllPublications() {
        return publicationService.getAllPublications();
    }

    // Récupérer une publication par ID
    @GetMapping("/{id}")
    public Optional<Publication> getPublicationById(@PathVariable Long id) {
        return publicationService.getPublicationById(id);
    }

    // Modifier une publication
    @PutMapping("/{id}")
    public Publication updatePublication(@PathVariable Long id, @RequestBody Publication updatedPublication) {
        return publicationService.updatePublication(id, updatedPublication);
    }

    // Supprimer une publication
    @DeleteMapping("/{id}")
    public void deletePublication(@PathVariable Long id) {
        publicationService.deletePublication(id);
    }

    // Récupérer toutes les publications d’un utilisateur (Professional)
    @GetMapping("/user/{userId}")
    public List<Publication> getPublicationsByUser(@PathVariable Long userId) {
        return publicationService.getPublicationsByUserId(userId);
    }

    // Ajouter un like
    @PostMapping("/{id}/like")
    public Publication likePublication(@PathVariable Long id) {
        return publicationService.likePublication(id);
    }

    // Supprimer un like
    @PostMapping("/{id}/unlike")
    public Publication unlikePublication(@PathVariable Long id) {
        return publicationService.unlikePublication(id);
    }

    @PutMapping("/{id}/content")
    public Publication updatePublicationContent(@PathVariable Long id, @RequestBody Map<String, String> request) {
        String newContent = request.get("contenu");
        if (newContent == null || newContent.trim().isEmpty()) {
            throw new RuntimeException("Le contenu ne peut pas être vide");
        }
        return publicationService.updatePublicationContent(id, newContent);
    }


}
