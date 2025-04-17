package com.sosMaison.sosMaison.Professional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;

public interface ProfesionalRepository extends JpaRepository<Professional,Long> {
    @Query("SELECT p FROM Professional p LEFT JOIN FETCH p.evaluations WHERE p.id = :id")
    Optional<Professional> findByIdWithEvaluations(@Param("id") Long id);
}
