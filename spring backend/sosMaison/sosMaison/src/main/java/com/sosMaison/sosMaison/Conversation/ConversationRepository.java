package com.sosMaison.sosMaison.Conversation;

import com.sosMaison.sosMaison.User.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.*;

public interface ConversationRepository extends JpaRepository<Conversation, Long> {
    Optional<Conversation> findByAuteurAndRecepteur(User auteur, User recepteur);

    List<Conversation> findByAuteurOrRecepteur(User userOne, User userTwo);
}
