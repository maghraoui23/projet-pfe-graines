package com.sosMaison.sosMaison.AuthService;

import com.sosMaison.sosMaison.AuthModel.AdminLoginBody;
import com.sosMaison.sosMaison.AuthModel.LoginBody;
import com.sosMaison.sosMaison.AuthModel.ProfessionalLoginBody;
import com.sosMaison.sosMaison.AuthModel.RegistrationBody;
import com.sosMaison.sosMaison.User.Role;
import com.sosMaison.sosMaison.User.User;
import com.sosMaison.sosMaison.User.UserRepository;
import com.sosMaison.sosMaison.User.UserRepository;
import org.springframework.security.authentication.AnonymousAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Service;


import java.util.*;

@Service
public class Userservice {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private EncryptionService encryptionService;

    @Autowired
    private JWTservice jwtService;

    @Autowired
    private JavaMailSender mailSender;

    // Enregistrement client standard
    public String registerUser(RegistrationBody body) {
        User user = new User();
        mapRegistrationToUser(body, user);
        user.setRole(Role.CLIENT);
        return saveUserAndGenerateToken(user);
    }

    // Enregistrement professionnel (réservé aux admins)
    public String registerProfessional(RegistrationBody body, Authentication auth) {
        checkAdminAuthority(auth);
        User user = new User();
        mapRegistrationToUser(body, user);
        user.setRole(Role.PROFESSIONNEL);
        return saveUserAndGenerateToken(user);
    }

    // Enregistrement admin (réservé aux admins)
    public String registerAdmin(RegistrationBody body, Authentication auth) {
        checkAdminAuthority(auth);
        User user = new User();
        mapRegistrationToUser(body, user);
        user.setRole(Role.ADMIN);
        return saveUserAndGenerateToken(user);
    }

    // Connexion client
    public String clientLogin(LoginBody body) {
        User user = userRepository.findByUsername(body.getUsername())
                .orElseThrow(() -> new SecurityException("Identifiants invalides"));
        return authenticateUser(user, body.getPassword());
    }

    // Connexion professionnel
    public String professionalLogin(ProfessionalLoginBody body) {
        User user = userRepository.findByphoneNumber(body.getPhoneNumber())
                .orElseThrow(() -> new SecurityException("Identifiants invalides"));
        return authenticateUser(user, body.getPassword());
    }

    // Connexion admin
    public String adminLogin(AdminLoginBody body) {
        User user = userRepository.findByEmail(body.getEmail())
                .orElseThrow(() -> new SecurityException("Identifiants invalides"));
        return authenticateUser(user, body.getPassword());
    }

    private void mapRegistrationToUser(RegistrationBody body, User user) {
        user.setUsername(body.getUsername());
        user.setEmail(body.getEmail());
        user.setPassword(encryptionService.encryptPassword(body.getPassword()));
        user.setFirstName(body.getFirstName());
        user.setLastName(body.getLastName());
        user.setPhoneNummber(body.getPhoneNumber());
    }

    private String saveUserAndGenerateToken(User user) {
        try {
            userRepository.save(user);
            return jwtService.generateJWT(user);
        } catch (DataIntegrityViolationException e) {
            throw new SecurityException("Erreur d'enregistrement : données dupliquées");
        }
    }

    private String authenticateUser(User user, String rawPassword) {
        if (!encryptionService.verifyPassword(rawPassword, user.getPassword())) {
            throw new SecurityException("Identifiants invalides");
        }
        return jwtService.generateJWT(user);
    }

    public void checkAdminAuthority(Authentication auth) {
        if (auth == null || !auth.getAuthorities().stream()
                .anyMatch(a -> a.getAuthority().equals("ROLE_ADMIN"))) {
            throw new AccessDeniedException("Accès refusé");
        }
    }

    public User getUserById(Long receiverId) {
        return userRepository.findById(receiverId)
                .orElseThrow(() -> new IllegalArgumentException("User not found."));
    }
    private boolean isPasswordHashed(String password) {
        return password != null && password.startsWith("$2a$");
    }

    public void migrateProfessionals() {
        List<User> professionals = userRepository.findByRoleIsNull();

        for (User user : professionals) {
            user.setRole(Role.PROFESSIONNEL);

            // Gérer les mots de passe vides/nuls
            if (user.getPassword() == null || user.getPassword().isBlank()) {
                String tempPassword = UUID.randomUUID().toString().substring(0, 8);
                user.setPassword(encryptionService.encryptPassword(tempPassword));
            }
            // Vérifier si le mot de passe est déjà hashé
            else if (!isPasswordHashed(user.getPassword())) {
                user.setPassword(encryptionService.encryptPassword(user.getPassword()));
            }

            userRepository.save(user);
        }
    }

    private void sendSmsNotification(String phoneNumber, String message) {
        String carrierGateway = getCarrierGateway(phoneNumber);
        if (carrierGateway != null) {
            SimpleMailMessage email = new SimpleMailMessage();
            email.setTo(phoneNumber + carrierGateway);
            email.setSubject("");
            email.setText(message);
            mailSender.send(email);
        }
    }

    private String getCarrierGateway(String phoneNumber) {
        // Format tunisien : +216 XX XXX XXX → 9XXXXXXX
        String localNumber = phoneNumber.replace("+216", "9");

        if (localNumber.startsWith("95") || localNumber.startsWith("96")) { // Ooredoo
            return "@sms.ooredoo.tn";
        } else if (localNumber.startsWith("97") || localNumber.startsWith("98")) { // Orange TN
            return "@sms.orange.tn";
        } else if (localNumber.startsWith("99") || localNumber.startsWith("92")) { // Tunisie Telecom
            return "@sms.tunicell.tn";
        } else if (localNumber.startsWith("93") || localNumber.startsWith("94")) { // LycaMobile
            return "@sms.lycamobile.tn";
        }
        return null;
    }

    private void validatePhoneNumber(String phoneNumber) {
        if (!phoneNumber.startsWith("+216")) {
            throw new IllegalArgumentException("Numéro tunisien requis (+216)");
        }
        if (phoneNumber.length() != 12) { // +216 92 640 725
            throw new IllegalArgumentException("Format invalide");
        }
    }

    public void changePassword(User user, String oldPassword, String newPassword) {
        if (!encryptionService.verifyPassword(oldPassword, user.getPassword())) {
            throw new SecurityException("Ancien mot de passe incorrect");
        }
        user.setPassword(encryptionService.encryptPassword(newPassword));
        userRepository.save(user);

        sendSmsNotification(user.getPhoneNummber(),
                "SOS Maison : Votre mot de passe a été modifié avec succès");
    }

    public void resetPasswordByPhone(String phoneNumber, String newPassword) {
        validatePhoneNumber(phoneNumber);
        User user = userRepository.findByphoneNumber(phoneNumber)
                .orElseThrow(() -> new SecurityException("Numéro non trouvé"));

        user.setPassword(encryptionService.encryptPassword(newPassword));
        userRepository.save(user);

        sendSmsNotification(phoneNumber,
                "SOS Maison : Votre mot de passe a été réinitialisé. Nouveau pass : " + newPassword);
    }
    @Transactional
    public User getCurrentUser() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication != null && authentication.isAuthenticated()) {
            return (User ) authentication.getPrincipal();
        }
        throw new SecurityException("No authenticated user found");
    }
    public boolean isLoggedIn() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        return !(authentication instanceof AnonymousAuthenticationToken) && authentication.isAuthenticated();
    }






}