package com.sosMaison.sosMaison.likes;

import com.sosMaison.sosMaison.Publication.PublicatioRepository;
import com.sosMaison.sosMaison.Publication.Publication;
import com.sosMaison.sosMaison.User.User;
import com.sosMaison.sosMaison.User.UserRepository;
import org.springframework.beans.factory.annotation.*;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class LikeService {
    @Autowired
    private LikeRepository likeRepository;

    @Autowired
    private PublicatioRepository publicationRepository;

    @Autowired
    private UserRepository userRepository;

    public void likeOrUnlike(Long userId, Long publicationId) {
        Optional<User> userOpt = userRepository.findById(userId);
        Optional<Publication> publicationOpt = publicationRepository.findById(publicationId);

        if (userOpt.isPresent() && publicationOpt.isPresent()) {
            User user = userOpt.get();
            Publication publication = publicationOpt.get();

            Optional<LikeEntity> existingLike = likeRepository.findByUserAndPublication(user, publication);

            if (existingLike.isPresent()) {
                // Si le like existe déjà, on le supprime (unlike)
                likeRepository.delete(existingLike.get());
                publication.setLikes(publication.getLikes() - 1);
            } else {
                // Sinon, on ajoute un like
                LikeEntity like = new LikeEntity();
                like.setUser(user);
                like.setPublication(publication);
                likeRepository.save(like);
                publication.setLikes(publication.getLikes() + 1);
            }

            publicationRepository.save(publication);
        } else {
            throw new RuntimeException("Utilisateur ou publication non trouvée");
        }
    }

    public boolean hasUserLiked(Long userId, Long publicationId) {
        Optional<User> user = userRepository.findById(userId);
        Optional<Publication> publication = publicationRepository.findById(publicationId);

        return user.isPresent() && publication.isPresent() &&
                likeRepository.findByUserAndPublication(user.get(), publication.get()).isPresent();
    }
    // Récupère tous les likes d'une publication
    public List<LikeEntity> getLikesForPublication(Long publicationId) {
        Optional<Publication> publicationOpt = publicationRepository.findById(publicationId);
        if (publicationOpt.isPresent()) {
            return likeRepository.findByPublication(publicationOpt.get());
        } else {
            throw new RuntimeException("Publication non trouvée");
        }
    }

    // Compte le nombre de likes pour une publication
    public long countLikesForPublication(Long publicationId) {
        return getLikesForPublication(publicationId).size();
    }
}
