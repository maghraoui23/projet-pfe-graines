package com.sosMaison.sosMaison.User;


import lombok.Data;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.Collections;
import java.util.List;
import java.util.Optional;

@Service
@Data
public class UserService {

    @Autowired
    UserRepository UserRepository;


    //creer
    public User createUser(User user) {
        return UserRepository.save(user);
    }


    //get users
    public List<User> getALlUsers(){
        return UserRepository.findAll();

    }
    //get user by id
    public Optional<User> getUserById(Long id) {
        return UserRepository.findById(id);
    }

    //update user
    public User UpdateUser(Long id, User user) {
        Optional<User> userOptional = UserRepository.findById(id);
        if(userOptional.isPresent()) {
            User updatedUser = userOptional.get();
            updatedUser.setFirstName(user.getFirstName());
            updatedUser.setLastName(user.getLastName());
            updatedUser.setEmail(user.getEmail());
            updatedUser.setPassword(user.getPassword());
            updatedUser.setRole(user.getRole());
            updatedUser.setPhoneNummber(user.getPhoneNummber());
            updatedUser.setPhoto(user.getPhoto());
            updatedUser.setUsername(user.getUsername());

            return UserRepository.save(updatedUser);
        }
        return null;
    }

    //delete user
    public void deleteUser(Long id) {
        UserRepository.deleteById(id);
    }
    //delete all
    public void deleteAllUsers() {
        UserRepository.deleteAll();
    }

    public User updateUserPhoto(Long id, String photoUrl) {
        Optional<User> userOptional = UserRepository.findById(id);
        if(userOptional.isPresent()) {
            User user = userOptional.get();
            user.setPhoto(photoUrl); // Utilisez la casse exacte de votre entité (Photo avec P majuscule)
            return UserRepository.save(user);
        }
        return null;
    }

    // Méthode pour récupérer par username (nécessaire pour la validation JWT)
    public Optional<User> getUserByUsername(String username) {
        return UserRepository.findByUsername(username);
    }

    public List<User> searchUsers(String query) {
        if (query.length() < 2) {
            return Collections.emptyList(); // On évite les recherches inutiles sur 1 caractère
        }
        return UserRepository.searchUsers(query);
    }





}
