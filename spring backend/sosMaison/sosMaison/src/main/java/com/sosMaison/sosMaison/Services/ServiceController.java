package com.sosMaison.sosMaison.Controllers;

import com.sosMaison.sosMaison.Services.Service;
import com.sosMaison.sosMaison.Services.ServiceService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/services")
public class ServiceController {

    @Autowired
    private ServiceService serviceService;

    // Get all services
    @GetMapping
    public List<Service> getAllServices() {
        return serviceService.getAllServices();
    }

    // Get service by ID
    @GetMapping("/{id}")
    public ResponseEntity<Service> getServiceById(@PathVariable Long id) {
        Optional<Service> service = serviceService.getServiceById(id);
        return service.map(ResponseEntity::ok).orElseGet(() -> ResponseEntity.notFound().build());
    }

    // Create a new service
    @PostMapping
    public Service createService(@RequestBody Service service) {
        return serviceService.addService(service);
    }

    // Update an existing service
    @PutMapping("/{id}")
    public ResponseEntity<Service> updateService(@PathVariable Long id, @RequestBody Service updatedService) {
        Service service = serviceService.updateService(updatedService, id);
        return service != null ? ResponseEntity.ok(service) : ResponseEntity.notFound().build();
    }

    // Delete a service
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteService(@PathVariable Long id) {
        serviceService.supprimerService(id);
        return ResponseEntity.noContent().build();
    }
}