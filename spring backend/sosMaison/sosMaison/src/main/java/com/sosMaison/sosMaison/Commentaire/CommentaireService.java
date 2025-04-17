package com.sosMaison.sosMaison.Commentaire;

import com.sosMaison.sosMaison.Publication.PublicatioRepository;
import com.sosMaison.sosMaison.Publication.Publication;
import com.sosMaison.sosMaison.User.User;
import com.sosMaison.sosMaison.User.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class CommentaireService {

    @Autowired
    private CommentaireRepository commentaireRepository;

    @Autowired
    private PublicatioRepository publicationRepository;

    @Autowired
    private UserRepository userRepository;

    // Ajouter un commentaire
    public Commentaire addComment(Long userId, Long publicationId, String contenu) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé"));
        Publication publication = publicationRepository.findById(publicationId)
                .orElseThrow(() -> new RuntimeException("Publication non trouvée"));

        Commentaire commentaire = new Commentaire();
        commentaire.setAuteur(user);
        commentaire.setContenu(contenu);
        commentaire.setPublication(publication);
        return commentaireRepository.save(commentaire);
    }

    // Supprimer un commentaire
    public void deleteComment(Long id) {
        commentaireRepository.deleteById(id);
    }

    // Récupérer tous les commentaires d'une publication
    public List<Commentaire> getCommentsByPublication(Long publicationId) {
        return commentaireRepository.findByPublicationId(publicationId);
    }
}
