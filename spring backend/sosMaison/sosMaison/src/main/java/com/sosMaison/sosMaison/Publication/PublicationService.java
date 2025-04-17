package com.sosMaison.sosMaison.Publication;


import com.sosMaison.sosMaison.User.User;
import com.sosMaison.sosMaison.User.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.*;

@Service
public class PublicationService {

    @Autowired
    private PublicatioRepository publicationRepository;

    @Autowired
    private UserRepository userRepository;

    // Créer une publication
    public Publication createPublication(Long userId, Publication publication) {
        User auteur = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé"));
        publication.setAuteur(auteur);
        return publicationRepository.save(publication);
    }

    // Récupérer toutes les publications
    public List<Publication> getAllPublications() {
        return publicationRepository.findAll();
    }

    // Récupérer une publication par ID
    public Optional<Publication> getPublicationById(Long id) {
        return publicationRepository.findById(id);
    }

    // Modifier une publication
    public Publication updatePublication(Long id, Publication updatedPublication) {
        return publicationRepository.findById(id).map(publication -> {
            publication.setImage(updatedPublication.getImage());
            publication.setContenu(updatedPublication.getContenu());
            publication.setLikes(updatedPublication.getLikes());
            publication.setCommentaires(updatedPublication.getCommentaires());
            return publicationRepository.save(publication);
        }).orElseThrow(() -> new RuntimeException("Publication non trouvée"));
    }

    // Supprimer une publication
    public void deletePublication(Long id) {
        publicationRepository.deleteById(id);
    }

    // Récupérer toutes les publications d’un utilisateur (Professional)
    public List<Publication> getPublicationsByUserId(Long userId) {
        return publicationRepository.findByAuteurId(userId);
    }

    // Ajouter un like
    public Publication likePublication(Long id) {
        return publicationRepository.findById(id).map(publication -> {
            publication.addLike();
            return publicationRepository.save(publication);
        }).orElseThrow(() -> new RuntimeException("Publication non trouvée"));
    }

    // Supprimer un like
    public Publication unlikePublication(Long id) {
        return publicationRepository.findById(id).map(publication -> {
            publication.removeLike();
            return publicationRepository.save(publication);
        }).orElseThrow(() -> new RuntimeException("Publication non trouvée"));
    }
    // Modifier uniquement le contenu d'une publication
    public Publication updatePublicationContent(Long id, String newContent) {
        return publicationRepository.findById(id).map(publication -> {
            publication.setContenu(newContent);
            return publicationRepository.save(publication);
        }).orElseThrow(() -> new RuntimeException("Publication non trouvée"));
    }


}

