package com.sosMaison.sosMaison.ForumPost;

import com.sosMaison.sosMaison.AuthService.Userservice;
import com.sosMaison.sosMaison.Subreddit.Subreddit;
import com.sosMaison.sosMaison.Subreddit.SubredditNotFoundException;
import com.sosMaison.sosMaison.Subreddit.SubredditRepository;
import com.sosMaison.sosMaison.User.User;
import com.sosMaison.sosMaison.User.UserRepository;
import com.sosMaison.sosMaison.Vote.VoteRepository;
import jakarta.transaction.Transactional;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

import static java.util.stream.Collectors.toList;

@Service
@AllArgsConstructor
@Slf4j
@Transactional
public class PostService {

    private final PostRepository postRepository;
    private final SubredditRepository subredditRepository;
    private final UserRepository userRepository;
    private final Userservice authService;
    private final PostMapper postMapper;
    private final VoteRepository voteRepository;


    public void save(PostRequest postRequest) {
        Subreddit subreddit = subredditRepository.findByName(postRequest.getSubredditName())
                .orElseThrow(() -> new SubredditNotFoundException(postRequest.getSubredditName()));
        postRepository.save(postMapper.map(postRequest, subreddit, authService.getCurrentUser()));
    }

    @Transactional
    public PostResponse getPost(Long id) {
        Post post = postRepository.findById(id)
                .orElseThrow(() -> new PostNotFoundException(id.toString()));
        return postMapper.mapToDto(post);
    }

    @Transactional
    public List<PostResponse> getAllPosts() {
        return postRepository.findAll()
                .stream()
                .map(postMapper::mapToDto)
                .collect(toList());
    }

    @Transactional
    public List<PostResponse> getPostsBySubreddit(Long subredditId) {
        Subreddit subreddit = subredditRepository.findById(subredditId)
                .orElseThrow(() -> new SubredditNotFoundException(subredditId.toString()));
        List<Post> posts = postRepository.findAllBySubreddit(subreddit);
        return posts.stream().map(postMapper::mapToDto).collect(toList());
    }

    @Transactional
    public List<PostResponse> getPostsByUsername(String username) {
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new UsernameNotFoundException(username));
        return postRepository.findByUser(user)
                .stream()
                .map(postMapper::mapToDto)
                .collect(toList());
    }

    @Transactional
    public void deletePost(Long id) {
        Post post = postRepository.findById(id)
                .orElseThrow(() -> new PostNotFoundException(id.toString()));

        // Delete votes associated with the post
        voteRepository.deleteByPost(post); // Ensure you have this method in your VoteRepository

        // Now delete the post
        postRepository.delete(post);
    }
    public List<PostResponse> searchPosts(String searchTerm) {
        return postRepository.searchPosts(searchTerm)
                .stream()
                .map(postMapper::mapToDto)
                .collect(Collectors.toList());
    }


}