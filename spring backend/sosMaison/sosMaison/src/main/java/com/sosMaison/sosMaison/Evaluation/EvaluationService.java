package com.sosMaison.sosMaison.Evaluation;

import com.sosMaison.sosMaison.Professional.ProfesionalRepository;
import com.sosMaison.sosMaison.Professional.Professional;
import com.sosMaison.sosMaison.User.User;
import com.sosMaison.sosMaison.User.UserRepository;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
public class EvaluationService {
    private final EvaluationRepository evaluationRepository;
    private final UserRepository userRepository;
    private final ProfesionalRepository professionalRepository;

    public EvaluationService(EvaluationRepository evaluationRepository, UserRepository userRepository, ProfesionalRepository professionalRepository) {
        this.evaluationRepository = evaluationRepository;
        this.userRepository = userRepository;
        this.professionalRepository=professionalRepository;
    }

    public Evaluation ajouterEvaluation(Long userId, Long professionalId, int rating, String comment) {
        Optional<User> user = userRepository.findById(userId);
        Optional<Professional> professional = professionalRepository.findById(professionalId);

        if (user.isPresent() && professional.isPresent() && rating >= 1 && rating <= 5) {
            Evaluation evaluation = new Evaluation(null, user.get(), professional.get(), rating, comment, null);
            return evaluationRepository.save(evaluation);
        }
        throw new RuntimeException("Utilisateur ou Professionnel introuvable ou Note invalide");
    }

    public List<Evaluation> getEvaluationsByProfessional(Long professionalId) {
        return evaluationRepository.findByProfessionalId(professionalId);
    }

    public double getMoyenneAvis(Long professionalId) {
        return evaluationRepository.getMoyenneAvis(professionalId);
    }

    public Evaluation updateEvaluation(Long evaluationId, int newRating, String newComment) {
        Optional<Evaluation> evaluationOpt = evaluationRepository.findById(evaluationId);

        if (evaluationOpt.isPresent() && newRating >= 1 && newRating <= 5) {
            Evaluation evaluation = evaluationOpt.get();
            evaluation.setRating(newRating);
            evaluation.setComment(newComment);
            evaluation.setDateEvaluation(LocalDateTime.now());
            return evaluationRepository.save(evaluation);
        }
        throw new RuntimeException("Évaluation introuvable ou note invalide");
    }

    public boolean hasUserEvaluatedProfessional(Long userId, Long professionalId) {
        return evaluationRepository.existsByUser_IdAndProfessional_Id(userId, professionalId);
    }

    public void supprimerEvaluation(Long evaluationId) {
        if (evaluationRepository.existsById(evaluationId)) {
            evaluationRepository.deleteById(evaluationId);
        } else {
            throw new RuntimeException("Évaluation introuvable");
        }
    }

}
