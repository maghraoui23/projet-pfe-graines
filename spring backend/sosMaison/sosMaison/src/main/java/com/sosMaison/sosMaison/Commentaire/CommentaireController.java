package com.sosMaison.sosMaison.Commentaire;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/commentaires")
public class CommentaireController {

    @Autowired
    private CommentaireService commentaireService;

    @PostMapping("/user/{userId}/publication/{publicationId}")
    public Commentaire addComment(@PathVariable Long userId, @PathVariable Long publicationId, @RequestBody String contenu) {
        return commentaireService.addComment(userId, publicationId, contenu);
    }

    @DeleteMapping("/{id}")
    public void deleteComment(@PathVariable Long id) {
        commentaireService.deleteComment(id);
    }

    @GetMapping("/publication/{publicationId}")
    public List<Commentaire> getCommentsByPublication(@PathVariable Long publicationId) {
        return commentaireService.getCommentsByPublication(publicationId);
    }
}