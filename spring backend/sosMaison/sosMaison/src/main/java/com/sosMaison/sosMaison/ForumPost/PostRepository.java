package com.sosMaison.sosMaison.ForumPost;

import com.sosMaison.sosMaison.Subreddit.Subreddit;
import com.sosMaison.sosMaison.User.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface PostRepository extends JpaRepository<Post, Long> {
    List<Post> findAllBySubreddit(Subreddit subreddit);

    List<Post> findByUser(User user);
    @Query("SELECT p FROM Post p WHERE LOWER(p.postName) LIKE LOWER(CONCAT('%', :searchTerm, '%')) " +
            "OR LOWER(p.url) LIKE LOWER(CONCAT('%', :searchTerm, '%')) " +
            "OR LOWER(p.user.username) LIKE LOWER(CONCAT('%', :searchTerm, '%'))")
    List<Post> searchPosts(@Param("searchTerm") String searchTerm);
}
