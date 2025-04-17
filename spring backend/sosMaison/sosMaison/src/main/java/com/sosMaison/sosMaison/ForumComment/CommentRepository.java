package com.sosMaison.sosMaison.ForumComment;

import com.sosMaison.sosMaison.ForumPost.Post;
import com.sosMaison.sosMaison.User.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface CommentRepository extends JpaRepository<Comment, Long> {
    List<Comment> findByPost(Post post);

    List<Comment> findAllByUser(User user);

    List<Comment> findByPostOrderByCreatedDateAsc(Post post);
}
