package com.sosMaison.sosMaison.Evaluation;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/evaluations")
public class EvaluationController {
    private final EvaluationService evaluationService;

    public EvaluationController(EvaluationService evaluationService) {
        this.evaluationService = evaluationService;
    }

    @PostMapping("/ajouter")
    public Evaluation ajouterEvaluation(@RequestParam Long userId, @RequestParam Long professionalId, @RequestParam int rating, @RequestParam(required = false) String comment) {
        return evaluationService.ajouterEvaluation(userId, professionalId, rating, comment);
    }

    @GetMapping("/{professionalId}")
    public List<Evaluation> getEvaluations(@PathVariable Long professionalId) {
        return evaluationService.getEvaluationsByProfessional(professionalId);
    }
    @PutMapping("/update/{evaluationId}")
    public Evaluation updateEvaluation(
            @PathVariable Long evaluationId,
            @RequestParam int newRating,
            @RequestParam(required = false) String newComment) {

        return evaluationService.updateEvaluation(evaluationId, newRating, newComment);
    }

    @GetMapping("/check-evaluation")
    public boolean checkUserEvaluation(
            @RequestParam Long userId,
            @RequestParam Long professionalId) {

        return evaluationService.hasUserEvaluatedProfessional(userId, professionalId);
    }
    @DeleteMapping("/delete/{evaluationId}")
    public ResponseEntity<String> supprimerEvaluation(@PathVariable Long evaluationId) {
        try {
            evaluationService.supprimerEvaluation(evaluationId);
            return ResponseEntity.ok("Évaluation supprimée avec succès");
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(e.getMessage());
        }
    }
}
