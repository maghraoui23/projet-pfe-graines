package com.sosMaison.sosMaison.likes;

import com.sosMaison.sosMaison.Publication.Publication;
import com.sosMaison.sosMaison.User.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface LikeRepository extends JpaRepository<LikeEntity, Long> {
    Optional<LikeEntity> findByUserAndPublication(User user, Publication publication);
    List<LikeEntity> findByPublication(Publication publication);
}
