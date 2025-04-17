package com.sosMaison.sosMaison.OAuth2;

import com.sosMaison.sosMaison.OAuth2.CustomOAuth2User;
import com.sosMaison.sosMaison.AuthService.JWTservice;
import com.sosMaison.sosMaison.User.UserRepository;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.io.IOException;
import java.util.Collections;
import java.util.Map;

@RestController
@RequestMapping("/auth/oauth2")
public class OAuth2Controller {

    private final JWTservice jwtService;
    private final UserRepository userRepository;

    public OAuth2Controller(JWTservice jwtService, UserRepository userRepository) {
        this.jwtService = jwtService;
        this.userRepository = userRepository;
    }

    @GetMapping("/success")
    public ResponseEntity<?> oauth2Success(HttpServletResponse response,
                                           @AuthenticationPrincipal CustomOAuth2User oauthUser) throws IOException {

        // Générer le JWT
        String token = jwtService.generateJWT(oauthUser.getUser());

        // Rediriger vers l'app Flutter avec le token
        response.sendRedirect("votre_schema_app://oauth2callback?token=" + token);

        return ResponseEntity.ok().build();
    }

    @GetMapping("/failure")
    public ResponseEntity<?> oauth2Failure(HttpServletResponse response) throws IOException {
        response.sendRedirect("votre_schema_app://oauth2callback?error=auth_failed");
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
    }
}