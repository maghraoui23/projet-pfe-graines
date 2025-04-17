package com.sosMaison.sosMaison.Security;


import com.sosMaison.sosMaison.AuthService.JWTservice;
import com.sosMaison.sosMaison.OAuth2.CustomOAuth2User;
import com.sosMaison.sosMaison.OAuth2.CustomOAuth2UserService;
import com.sosMaison.sosMaison.User.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import java.util.List;

@Configuration
@EnableWebSecurity
@EnableMethodSecurity
public class WebSecurity {

    private final JWTRequestFIlter jwtFilter;
    private final JWTservice jwtService;
    private final UserRepository userRepository;
    @Autowired
    private CustomOAuth2UserService customOAuth2UserService;


    public WebSecurity(JWTRequestFIlter jwtFilter,
                       JWTservice jwtService,
                       UserRepository userRepository,CustomOAuth2UserService customOAuth2UserService
                       ) {
        this.jwtFilter = jwtFilter;
        this.jwtService = jwtService;
        this.userRepository = userRepository;
        this.customOAuth2UserService=customOAuth2UserService;

    }

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
                .csrf(AbstractHttpConfigurer::disable)
                .cors(cors -> cors.configurationSource(corsConfigurationSource()))
                .sessionManagement(session -> session
                        .sessionCreationPolicy(SessionCreationPolicy.STATELESS)
                ) .oauth2Login(oauth -> oauth
                        .userInfoEndpoint(userInfo -> userInfo
                                .userService(customOAuth2UserService)
                        )
                        .successHandler((request, response, authentication) -> {
                            CustomOAuth2User oauthUser = (CustomOAuth2User) authentication.getPrincipal();
                            String jwtToken = jwtService.generateJWT(oauthUser.getUser());
                            response.sendRedirect("/auth/oauth2/success?token=" + jwtToken);
                        })
                        .failureHandler((request, response, exception) -> {
                            response.sendRedirect("/auth/oauth2/failure");
                        })
                )

                .authorizeHttpRequests(auth -> auth
                        .requestMatchers(
                                "/auth/oauth2/**", // Ajout des endpoints OAuth2
                                "/services", "/clients", "/users/**", "/professionals/**",
                                "api/posts/**","/api/comments/**",
                                "/chat_messages/conversations/**", "/migrate-professionals",
                                "/publications/**", "/commentaires/**", "/likes/**", "/evaluations/**",
                                "/api/subreddit/**","/api/posts/**","/api/comments/**","/api/votes/**",
                                "/auth/login/client", "/auth/register/client",
                                "/auth/login/professional", "/auth/register/professional",
                                "/professionals/{id}/update-photo-phone", "/auth/reset-password",
                                "/auth/login/admin", "/auth/me", "/uploads/**",
                                "/users/{id}/uploadPhoto", "/auth/**"
                        ).permitAll()
                        .requestMatchers("/publications", "/professionals", "/chat_messages/conversations","/api/posts/**")
                        .hasRole("PROFESSIONNEL")
                        .requestMatchers("/commentaires", "/likes").hasRole("CLIENT")
                        .requestMatchers("/users", "/chat_messages/conversations").hasAnyRole("CLIENT", "ADMIN")
                        .requestMatchers("/**").hasRole("ADMIN")
                        .anyRequest().denyAll()
                )
                .addFilterBefore(jwtFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }

    // WebSecurity.java
    @Bean
    CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();
        configuration.setAllowedOrigins(List.of("*")); // En prod, spécifiez votre domaine Flutter
        configuration.setAllowedMethods(List.of("GET", "POST", "PUT", "DELETE"));
        configuration.addAllowedHeader("Authorization");
        configuration.setAllowCredentials(true);

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);
        return source;
    }
}