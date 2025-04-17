package com.sosMaison.sosMaison.Vote;

import com.sosMaison.sosMaison.ForumPost.Post;
import com.sosMaison.sosMaison.User.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface VoteRepository extends JpaRepository<Vote, Long> {
    Optional<Vote> findTopByPostAndUserOrderByVoteIdDesc(Post post, User currentUser);
    void deleteByPost(Post post);

}
