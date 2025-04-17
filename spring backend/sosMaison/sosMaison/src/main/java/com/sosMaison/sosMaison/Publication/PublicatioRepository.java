package com.sosMaison.sosMaison.Publication;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface PublicatioRepository extends JpaRepository<Publication,Long> {
    List<Publication> findByAuteurId(Long userId);
}
