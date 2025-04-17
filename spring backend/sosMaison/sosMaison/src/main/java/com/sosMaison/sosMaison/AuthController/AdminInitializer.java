/**package com.sosMaison.sosMaison.AuthController;

import com.sosMaison.sosMaison.User.User;
import com.sosMaison.sosMaison.User.Role;
import com.sosMaison.sosMaison.User.UserRepository;
import com.sosMaison.sosMaison.AuthService.EncryptionService;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;
import java.util.Optional;

@Component
public class AdminInitializer implements CommandLineRunner {

    private final UserRepository userRepository;
    private final EncryptionService encryptionService;

    public AdminInitializer(UserRepository userRepository, EncryptionService encryptionService) {
        this.userRepository = userRepository;
        this.encryptionService = encryptionService;
    }

    @Override
    public void run(String... args) throws Exception {
        String adminEmail = "mohamed.maghraoui@enicar.ucar.tn";
        Optional<User> existingAdmin = userRepository.findByEmail(adminEmail);

        if (existingAdmin.isEmpty()) {
            User admin = new User();
            admin.setFirstName("Mohamed Aziz");
            admin.setLastName("Maghraoui");
            admin.setEmail(adminEmail);
            admin.setPhoneNummber("93405296"); // Attention au nom de méthode avec 3 'm'
            admin.setPassword(encryptionService.encryptPassword("thisIsAdmin1"));
            admin.setRole(Role.ADMIN);
            admin.setUsername("Maghraoui_admin"); // À personnaliser si nécessaire

            // Vérification unicité username
            if (userRepository.findByUsername(admin.getUsername()).isPresent()) {
                throw new IllegalStateException("Username déjà utilisé");
            }

            userRepository.save(admin);
            System.out.println("Admin initial créé avec succès");
        }
    }
}
**/