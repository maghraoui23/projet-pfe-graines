package com.sosMaison.sosMaison.ForumComment;

import com.sosMaison.sosMaison.ForumPost.Post;
import com.sosMaison.sosMaison.User.User;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface CommentMapper {
    @Mapping(target = "id", ignore = true)
    @Mapping(target = "text", source = "commentsDto.text")
    @Mapping(target = "createdDate", expression = "java(java.time.Instant.now())")
    @Mapping(target = "post", source = "post")
    @Mapping(target = "user", source = "user")
    @Mapping(target = "parent", source = "parent")
    @Mapping(target = "replies", ignore = true) // Ajout de cette ligne
    Comment map(CommentsDto commentsDto, Post post, User user, Comment parent);

    @Mapping(target = "postId", expression = "java(comment.getPost().getPostId())")
    @Mapping(target = "userName", expression = "java(comment.getUser().getUsername())")
    @Mapping(target = "parentId", expression = "java(comment.getParent() != null ? comment.getParent().getId() : null)")
    @Mapping(target = "replies", ignore = true)
    CommentsDto mapToDto(Comment comment);
}