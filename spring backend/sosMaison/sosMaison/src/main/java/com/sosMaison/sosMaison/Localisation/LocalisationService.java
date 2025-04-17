package com.sosMaison.sosMaison.Localisation;

import org.springframework.beans.factory.annotation.*;
import org.springframework.stereotype.Service;
import java.util.*;

@Service
public class LocalisationService {
    @Autowired
    private LocalRepository localisationRepository;

    public List<Localisation> getAllLocalisations() {
        return localisationRepository.findAll();
    }

    public Optional<Localisation> getLocalisationById(Long id) {
        return localisationRepository.findById(id);
    }

    public Localisation createLocalisation(Localisation localisation) {
        return localisationRepository.save(localisation);
    }

    public Localisation updateLocalisation(Long id, Localisation updatedLocalisation) {
        return localisationRepository.findById(id)
                .map(localisation -> {
                    localisation.setLatitude(updatedLocalisation.getLatitude());
                    localisation.setLongitude(updatedLocalisation.getLongitude());
                    localisation.setAdresse(updatedLocalisation.getAdresse());
                    return localisationRepository.save(localisation);
                })
                .orElseThrow(() -> new RuntimeException("Localisation not found"));
    }

    public void deleteLocalisation(Long id) {
        localisationRepository.deleteById(id);
    }
}
