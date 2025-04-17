package com.sosMaison.sosMaison.Professional;

import org.springframework.beans.factory.annotation.*;
import org.springframework.stereotype.Service;

import java.util.*;

@Service
public class ProfessionalService {


    @Autowired
    ProfesionalRepository profesionalRepository;

    //getall
    public List<Professional> getAllProfessionals() {
        return profesionalRepository.findAll();
    }
    //getbyid

        // ProfessionalService.java
        public Optional<Professional> getProfessional(Long id) {
            return profesionalRepository.findByIdWithEvaluations(id);
        }

    //ajouter professionnal
    public Professional createProfessional(Professional professional) {
        return profesionalRepository.save(professional);
    }

    public Professional updateProfessional(Long id, Professional updatedProfessional) {
        Optional<Professional> professionalOptional = profesionalRepository.findById(id);
        if (professionalOptional.isPresent()) {
            Professional professional = professionalOptional.get();
            professional.setFirstName(updatedProfessional.getFirstName());
            professional.setLastName(updatedProfessional.getLastName());
            professional.setEmail(updatedProfessional.getEmail());
            professional.setPassword(updatedProfessional.getPassword());
            professional.setPhoneNummber(updatedProfessional.getPhoneNummber());
            professional.setPhoto(updatedProfessional.getPhoto());
            professional.setRole(updatedProfessional.getRole());
            professional.setLocalisation(updatedProfessional.getLocalisation());
            professional.setService(updatedProfessional.getService());
            professional.setExperience(updatedProfessional.getExperience());
            professional.setDiplomes(updatedProfessional.getDiplomes());

            professional.setPrix_service(updatedProfessional.getPrix_service());
            return profesionalRepository.save(professional);

        }
        return null;
    }

    public void deleteProfessional(Long id) {
        profesionalRepository.deleteById(id);
    }
    public Professional updateProfessionalPhotoAndPhone(Long id, String photo, String phoneNumber) {
        Optional<Professional> professionalOptional = profesionalRepository.findById(id);
        if (professionalOptional.isPresent()) {
            Professional professional = professionalOptional.get();
            professional.setPhoto(photo);
            professional.setPhoneNummber(phoneNumber);
            return profesionalRepository.save(professional);
        }
        return null;
    }

}
