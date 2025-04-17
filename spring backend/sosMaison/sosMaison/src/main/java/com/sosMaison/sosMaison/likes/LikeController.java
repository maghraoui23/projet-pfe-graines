package com.sosMaison.sosMaison.likes;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/likes")
public class LikeController {
    @Autowired
    private LikeService likeService;

    @PostMapping("/{userId}/{publicationId}")
    public String likeOrUnlike(@PathVariable Long userId, @PathVariable Long publicationId) {
        likeService.likeOrUnlike(userId, publicationId);
        return "Action effectuée avec succès";
    }

    @GetMapping("/{userId}/{publicationId}")
    public boolean hasUserLiked(@PathVariable Long userId, @PathVariable Long publicationId) {
        return likeService.hasUserLiked(userId, publicationId);
    }

    // Récupère tous les likes d'une publication
    @GetMapping("/publication/{publicationId}")
    public ResponseEntity<List<LikeEntity>> getLikesForPublication(@PathVariable Long publicationId) {
        return ResponseEntity.ok(likeService.getLikesForPublication(publicationId));
    }

    // Compte le nombre de likes pour une publication
    @GetMapping("/count/{publicationId}")
    public ResponseEntity<Long> countLikesForPublication(@PathVariable Long publicationId) {
        return ResponseEntity.ok(likeService.countLikesForPublication(publicationId));
    }
}