package com.sosMaison.sosMaison.AuthService;

import com.auth0.jwt.JWT;
import com.auth0.jwt.JWTVerifier;
import com.auth0.jwt.algorithms.Algorithm;
import com.auth0.jwt.exceptions.JWTVerificationException;
import com.auth0.jwt.interfaces.DecodedJWT;

import com.sosMaison.sosMaison.User.User;
import jakarta.annotation.PostConstruct;
import org.springframework.beans.factory.annotation.*;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.stereotype.Service;

import java.util.Date;
import java.util.List;

@Service
public class JWTservice {

    @Value("${jwt.secret}")
    private String secret;

    @Value("${jwt.expiry-in-seconds}")
    private int expiryInSeconds;

    private Algorithm algorithm;
    private JWTVerifier verifier;

    private static final String USERNAME_CLAIM = "username";
    private static final String ROLE_CLAIM = "role";

    @PostConstruct
    public void init() {
        // Conversion de la clé base64 en octets
        byte[] secretBytes = java.util.Base64.getDecoder().decode(secret);
        algorithm = Algorithm.HMAC256(secretBytes);
        verifier = JWT.require(algorithm).build();
    }

    public String generateJWT(User user) {
        if (user.getRole() == null) {
            throw new IllegalArgumentException("User role cannot be null");
        }

        return JWT.create()
                .withIssuer("SOS-Maison")
                .withSubject(user.getUsername())
                .withClaim(USERNAME_CLAIM, user.getUsername())
                .withClaim(ROLE_CLAIM, user.getRole().name())
                .withIssuedAt(new Date())
                .withExpiresAt(new Date(System.currentTimeMillis() + expiryInSeconds * 1000L))
                .sign(algorithm);
    }

    public DecodedJWT verifyJWT(String token) throws JWTVerificationException {
        return verifier.verify(token);
    }

    public String getUsernameFromJWT(String token) {
        return verifyJWT(token).getClaim(USERNAME_CLAIM).asString();
    }

    public String getRoleFromJWT(String token) {
        return verifyJWT(token).getClaim(ROLE_CLAIM).asString();
    }
    public String getuserNameFromJWT(String token){
        return verifyJWT(token).getClaim(USERNAME_CLAIM).asString();
    }

    public List<GrantedAuthority> getAuthoritiesFromJWT(String token) {
        String role = getRoleFromJWT(token);
        return List.of(new SimpleGrantedAuthority("ROLE_" + role));
    }
}