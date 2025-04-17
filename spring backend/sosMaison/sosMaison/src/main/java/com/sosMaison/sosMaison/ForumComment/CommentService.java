package com.sosMaison.sosMaison.ForumComment;
import com.sosMaison.sosMaison.AuthService.Userservice;
import com.sosMaison.sosMaison.ForumPost.Post;
import com.sosMaison.sosMaison.ForumPost.PostNotFoundException;
import com.sosMaison.sosMaison.ForumPost.PostRepository;
import com.sosMaison.sosMaison.Subreddit.SpringRedditException;
import com.sosMaison.sosMaison.User.User;
import com.sosMaison.sosMaison.User.UserRepository;
import lombok.AllArgsConstructor;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@AllArgsConstructor
public class CommentService {
    private static final String POST_URL = "";
    private final PostRepository postRepository;
    private final UserRepository userRepository;
    private final Userservice authService;
    private final CommentMapper commentMapper;
    private final CommentRepository commentRepository;


    public void save(CommentsDto commentsDto) {
        // Vérification simplifiée
        if (commentsDto.getText() == null || commentsDto.getText().isEmpty()) {
            throw new IllegalArgumentException("Comment text cannot be empty");
        }

        Post post;
        Comment parent = null;

        // Si c'est une réponse à un commentaire
        if (commentsDto.getParentId() != null) {
            parent = commentRepository.findById(commentsDto.getParentId())
                    .orElseThrow(() -> new CommentNotFoundException(commentsDto.getParentId().toString()));
            post = parent.getPost(); // Le post est celui du parent
        }
        // Si c'est un commentaire principal
        else if (commentsDto.getPostId() != null) {
            post = postRepository.findById(commentsDto.getPostId())
                    .orElseThrow(() -> new PostNotFoundException(commentsDto.getPostId().toString()));
        } else {
            throw new IllegalArgumentException("Either postId or parentId must be provided");
        }
        User currentUser = authService.getCurrentUser();
        Comment comment = commentMapper.map(commentsDto, post, currentUser, parent);
        commentRepository.save(comment);
    }

    public List<CommentsDto> getAllCommentsForPost(Long postId) {
        Post post = postRepository.findById(postId)
                .orElseThrow(() -> new PostNotFoundException(postId.toString()));
        List<Comment> comments = commentRepository.findByPostOrderByCreatedDateAsc(post);
        List<CommentsDto> commentDtos = comments.stream()
                .map(commentMapper::mapToDto)
                .collect(Collectors.toList());

        return buildCommentTree(commentDtos);
    }
    public List<CommentsDto> getAllCommentsForUser(String userName) {
        User user = userRepository.findByUsername(userName)
                .orElseThrow(() -> new UsernameNotFoundException(userName));
        return commentRepository.findAllByUser(user)
                .stream()
                .map(commentMapper::mapToDto)
                .toList();
    }

    public boolean containsSwearWords(String comment) {
        if (comment.contains("shit")) {
            throw new SpringRedditException("Comments contains unacceptable language");
        }
        return false;
    }
    private List<CommentsDto> buildCommentTree(List<CommentsDto> commentDtos) {
        Map<Long, CommentsDto> commentMap = new HashMap<>();
        List<CommentsDto> rootComments = new ArrayList<>();

        for (CommentsDto dto : commentDtos) {
            commentMap.put(dto.getId(), dto);
            if (dto.getParentId() == null) {
                rootComments.add(dto);
            } else {
                CommentsDto parent = commentMap.get(dto.getParentId());
                if (parent != null) {
                    if (parent.getReplies() == null) {
                        parent.setReplies(new ArrayList<>());
                    }
                    parent.getReplies().add(dto);
                }
            }
        }

        return rootComments;
    }
}