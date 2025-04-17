package com.sosMaison.sosMaison.Professional;

import com.sosMaison.sosMaison.Evaluation.EvaluationService;
import com.sosMaison.sosMaison.Professional.Professional;
import com.sosMaison.sosMaison.Professional.ProfessionalService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/professionals")
public class ProfessionalController {

    @Autowired
    private ProfessionalService professionalService;

    @Autowired
    private EvaluationService evaluationService;

    // Get all professionals
    @GetMapping
    public List<Professional> getAllProfessionals() {
        return professionalService.getAllProfessionals();
    }

    // Get professional by ID
    @GetMapping("/{id}")
    public ResponseEntity<Professional> getProfessional(@PathVariable Long id) {
        Optional<Professional> professional = professionalService.getProfessional(id);
        return professional.map(ResponseEntity::ok).orElseGet(() -> ResponseEntity.notFound().build());
    }

    // Create a new professional
    @PostMapping("/CreateProf")
    public Professional createProfessional(@RequestBody Professional professional) {
        return professionalService.createProfessional(professional);
    }

    // Update an existing professional
    @PutMapping("/{id}")
    public ResponseEntity<Professional> updateProfessional(@PathVariable Long id, @RequestBody Professional updatedProfessional) {
        Professional professional = professionalService.updateProfessional(id, updatedProfessional);
        return professional != null ? ResponseEntity.ok(professional) : ResponseEntity.notFound().build();
    }

    // Delete a professional
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteProfessional(@PathVariable Long id) {
        professionalService.deleteProfessional(id);
        return ResponseEntity.noContent().build();
    }
    @GetMapping("/{id}/moyenne-avis")
    public double getMoyenneAvis(@PathVariable Long id) {
        return evaluationService.getMoyenneAvis(id);
    }

    @PatchMapping("/{id}/update-photo-phone")
    public ResponseEntity<Professional> updateProfessionalPhotoAndPhone(
            @PathVariable Long id,
            @RequestParam String photo,
            @RequestParam String phoneNumber) {

        Professional professional = professionalService.updateProfessionalPhotoAndPhone(id, photo, phoneNumber);
        return professional != null ? ResponseEntity.ok(professional) : ResponseEntity.notFound().build();
    }

}