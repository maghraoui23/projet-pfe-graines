package com.sosMaison.sosMaison.OAuth2;

import com.sosMaison.sosMaison.User.Role;
import com.sosMaison.sosMaison.User.User;
import com.sosMaison.sosMaison.User.UserRepository;
import org.springframework.security.oauth2.client.userinfo.DefaultOAuth2UserService;
import org.springframework.security.oauth2.client.userinfo.OAuth2UserRequest;
import org.springframework.security.oauth2.core.OAuth2AuthenticationException;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.stereotype.Service;

import java.util.Map;
import java.util.Optional;

@Service
public class CustomOAuth2UserService extends DefaultOAuth2UserService {

    private final UserRepository userRepository;

    public CustomOAuth2UserService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @Override
    public OAuth2User loadUser(OAuth2UserRequest userRequest) throws OAuth2AuthenticationException {
        OAuth2User oAuth2User = super.loadUser(userRequest);
        return processOAuthUser(userRequest.getClientRegistration().getRegistrationId(), oAuth2User.getAttributes());
    }

    private OAuth2User processOAuthUser(String provider, Map<String, Object> attributes) {
        String email = (String) attributes.get("email");
        if (email == null) {
            throw new OAuth2AuthenticationException("Email not found from OAuth2 provider");
        }

        Optional<User> userOptional = userRepository.findByEmail(email);
        User user = userOptional.orElseGet(() -> createNewUser(provider, attributes, email));

        if (user.getProvider() == User.AuthProvider.LOCAL) {
            throw new OAuth2AuthenticationException("Email already registered with local account");
        }

        return new CustomOAuth2User(user, attributes);
    }
    private User createNewUser(String provider, Map<String, Object> attributes, String email) {
        User newUser = new User();
        newUser.setProvider(provider.equalsIgnoreCase("google") ?
                User.AuthProvider.GOOGLE : User.AuthProvider.FACEBOOK);
        newUser.setProviderId(getProviderId(provider, attributes));
        newUser.setEmail(email);
        newUser.setUsername(email);
        newUser.setFirstName(getFirstName(provider, attributes));
        newUser.setLastName(getLastName(provider, attributes));
        newUser.setRole(Role.CLIENT);
        return userRepository.save(newUser);
    }

    private String getProviderId(String provider, Map<String, Object> attributes) {
        return provider.equalsIgnoreCase("google") ?
                (String) attributes.get("sub") :
                (String) attributes.get("id");
    }

    private String getFirstName(String provider, Map<String, Object> attributes) {
        return provider.equalsIgnoreCase("google") ?
                (String) attributes.get("given_name") :
                (String) attributes.get("first_name");
    }

    private String getLastName(String provider, Map<String, Object> attributes) {
        return provider.equalsIgnoreCase("google") ?
                (String) attributes.get("family_name") :
                (String) attributes.get("last_name");
    }
}