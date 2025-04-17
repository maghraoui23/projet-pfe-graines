package com.sosMaison.sosMaison.Services;

import org.springframework.beans.factory.annotation.Autowired;

import java.util.List;
import java.util.Optional;


@org.springframework.stereotype.Service
public class ServiceService {

    @Autowired
    private ServiceRepository serviceRepository;
    public List<Service> getServiceRepository() {
        return serviceRepository.findAll();
    }

    //getall
    public List<Service> getAllServices(){
        return serviceRepository.findAll();
    }

    //get by id
    public Optional<Service> getServiceById(Long id) {
        return serviceRepository.findById(id);

    }
    //creer service
    public Service addService(Service service) {
        return serviceRepository.save(service);
    }
    //delete service
    public void supprimerService(Long id) {
        serviceRepository.deleteById(id);
    }

    //updatte service
    public Service updateService(Service updatedService,Long id) {
        Optional<Service> serviceOptional = serviceRepository.findById(id);
        if(serviceOptional.isPresent()) {
            Service service = serviceOptional.get();
            service.setId(updatedService.getId());
            service.setNom(updatedService.getNom());
            service.setDescription(updatedService.getDescription());
            service.setService_photo(updatedService.getService_photo());
            service.setCategorie(updatedService.getCategorie());
            service.setProfessionnels(updatedService.getProfessionnels());
            return serviceRepository.save(service);

        }
        return null;
    }
}
