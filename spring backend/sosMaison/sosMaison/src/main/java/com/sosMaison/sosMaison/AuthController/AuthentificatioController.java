package com.sosMaison.sosMaison.AuthController;


import com.sosMaison.sosMaison.AuthModel.*;
import com.sosMaison.sosMaison.AuthService.JWTservice;
import com.sosMaison.sosMaison.AuthService.Userservice;
import com.sosMaison.sosMaison.User.Role;
import com.sosMaison.sosMaison.User.User;
import com.sosMaison.sosMaison.User.UserRepository;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.Collections;
import java.util.Map;

@RestController
@RequestMapping("/auth")
public class AuthentificatioController {

    @Autowired
    private Userservice userservice;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private JWTservice jwtService;

    // Enregistrement client public
    @PostMapping("/register/client")
    public ResponseEntity<AuthResponse> registerClient(@RequestBody RegistrationBody body) {
        String token = userservice.registerUser(body);
        return ResponseEntity.ok(new AuthResponse(token));
    }

    // Enregistrement professionnel (admin seulement)
    @PostMapping("/register/professional")
    public ResponseEntity<AuthResponse> registerProfessional(
            @RequestBody RegistrationBody body,
            Authentication auth) {
        String token = userservice.registerProfessional(body, auth);
        return ResponseEntity.ok(new AuthResponse(token));
    }

    // Enregistrement admin (admin seulement)
    @PostMapping("/register/admin")
    public ResponseEntity<AuthResponse> registerAdmin(
            @RequestBody RegistrationBody body,
            Authentication auth) {
        String token = userservice.registerAdmin(body, auth);
        return ResponseEntity.ok(new AuthResponse(token));
    }

    // Connexion client
    @PostMapping("/login/client")
    public ResponseEntity<AuthResponse> loginClient(@RequestBody LoginBody body) {
        String token = userservice.clientLogin(body);
        return ResponseEntity.ok(new AuthResponse(token));
    }

    // Connexion professionnel
    @PostMapping("/login/professional")
    public ResponseEntity<AuthResponse> loginProfessional(@RequestBody ProfessionalLoginBody body) {
        String token = userservice.professionalLogin(body);
        return ResponseEntity.ok(new AuthResponse(token));
    }

    // Connexion admin
    @PostMapping("/login/admin")
    public ResponseEntity<AuthResponse> loginAdmin(@RequestBody AdminLoginBody body) {
        String token = userservice.adminLogin(body);
        return ResponseEntity.ok(new AuthResponse(token));
    }

    // Classe wrapper pour la réponse
    private static class AuthResponse {
        private final String token;

        public AuthResponse(String token) {
            this.token = token;
        }

        public String getToken() {
            return token;
        }
    }
    @GetMapping("/me")
    public User getLoggedInUserProfile(@AuthenticationPrincipal User user) {
        return user;
    }

    @PostMapping("/migrate-professionals")
    public ResponseEntity<String> migrateProfessionals(Authentication auth) {
        userservice.checkAdminAuthority(auth); // Utilisez la méthode existante de Userservice
        userservice.migrateProfessionals();
        return ResponseEntity.ok("Migration terminée");
    }
    // Changement de mot de passe classique
    @PostMapping("/change-password")
    public ResponseEntity<Void> changePassword(
            @RequestBody ChangePasswordRequest request,
            @AuthenticationPrincipal User user
    ) {
        userservice.changePassword(user, request.getOldPassword(), request.getNewPassword());
        return ResponseEntity.ok().build();
    }

    // Réinitialisation via SMS (nécessite intégration SMS)
    @PostMapping("/reset-password")
    public ResponseEntity<Void> resetPassword(
            @RequestParam String phoneNumber,
            @RequestParam String newPassword
    ) {
        userservice.resetPasswordByPhone(phoneNumber, newPassword);
        return ResponseEntity.ok().build();
    }

}



