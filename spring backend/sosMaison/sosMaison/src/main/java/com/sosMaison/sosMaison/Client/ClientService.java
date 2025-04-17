package com.sosMaison.sosMaison.Client;


import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class ClientService {

    @Autowired
    private ClientRepository clientRepository;


    //ajouter client
    public Client createClient(Client client) {
        return clientRepository.save(client);
    }

    //getAll clients
    public List<Client> getClients(){
        return clientRepository.findAll();

    }
    //getbyid
    public Optional<Client> getClient(Long id) {
        return clientRepository.findById(id);
    }
    public Client updateClient(Long id, Client updatedClient) {
        return clientRepository.findById(id)
                .map(client -> {
                    client.setFirstName(updatedClient.getFirstName());
                    client.setLastName(updatedClient.getLastName());
                    client.setEmail(updatedClient.getEmail());
                    client.setPassword(updatedClient.getPassword());
                    client.setPhoneNummber(updatedClient.getPhoneNummber());
                    client.setPhoto(updatedClient.getPhoto());
                    client.setRole(updatedClient.getRole());
                    client.setLocalisation(updatedClient.getLocalisation());
                    return clientRepository.save(client);
                })
                .orElseThrow(() -> new RuntimeException("Client not found"));
    }

    public void deleteClient(Long id) {
        clientRepository.deleteById(id);
    }





}
