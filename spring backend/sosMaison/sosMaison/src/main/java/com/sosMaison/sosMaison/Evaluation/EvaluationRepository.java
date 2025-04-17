package com.sosMaison.sosMaison.Evaluation;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;


public interface EvaluationRepository extends JpaRepository<Evaluation, Long> {
    List<Evaluation> findByProfessionalId(Long professionalId);
    @Query("SELECT COALESCE(AVG(e.rating), 0) FROM Evaluation e WHERE e.professional.id = :professionalId")
    double getMoyenneAvis(@Param("professionalId") Long professionalId);
    boolean existsByUser_IdAndProfessional_Id(Long userId, Long professionalId);
}