package com.sosMaison.sosMaison.Security;

import com.auth0.jwt.exceptions.JWTVerificationException;
import com.auth0.jwt.interfaces.DecodedJWT;
import com.sosMaison.sosMaison.AuthService.JWTservice;
import com.sosMaison.sosMaison.User.User;
import com.sosMaison.sosMaison.User.UserRepository;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.List;
import java.util.Optional;

@Component
public class JWTRequestFIlter extends OncePerRequestFilter {

    private final JWTservice jwtService;
    private final UserRepository userRepository;

    public JWTRequestFIlter(JWTservice jwtService, UserRepository userRepository) {
        this.jwtService = jwtService;
        this.userRepository = userRepository;
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {

        final String authorizationHeader = request.getHeader("Authorization");

        if (authorizationHeader != null && authorizationHeader.startsWith("Bearer ")) {
            String token = authorizationHeader.substring(7);

            try {
                // 1. Vérification complète du token
                DecodedJWT decodedJWT = jwtService.verifyJWT(token);

                // 2. Extraction des informations
                String username = jwtService.getUsernameFromJWT(token);
                String role = jwtService.getRoleFromJWT(token);

                // 3. Vérification de l'existence de l'utilisateur
                Optional<User> userOptional = userRepository.findByUsername(username);
                if (userOptional.isEmpty()) {
                    response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Utilisateur non trouvé");
                    return;
                }

                User user = userOptional.get();

                // 4. Vérification de la correspondance du rôle
                if (!user.getRole().name().equals(role)) {
                    response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Rôle modifié");
                    return;
                }

                // 5. Création de l'authentification
                List<GrantedAuthority> authorities = List.of(
                        new SimpleGrantedAuthority("ROLE_" + role)
                );

                UsernamePasswordAuthenticationToken authentication =
                        new UsernamePasswordAuthenticationToken(
                                user,
                                null,
                                authorities
                        );

                authentication.setDetails(
                        new WebAuthenticationDetailsSource().buildDetails(request)
                );

                SecurityContextHolder.getContext().setAuthentication(authentication);

                // ✅ Ajout de l'utilisateur dans la requête
                request.setAttribute("authenticatedUser", user);

            } catch (JWTVerificationException ex) {
                // Cas d'erreur de vérification
                response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Token invalide");
                return;
            }
        }

        filterChain.doFilter(request, response);
    }
}
