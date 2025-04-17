package com.sosMaison.sosMaison.Services;

import com.sosMaison.sosMaison.Client.Client;
import com.sosMaison.sosMaison.Professional.Professional;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;
@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor

public class DemandeService {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    private Client client;

    @ManyToOne
    private Professional professionnel;

    @ManyToOne
    private Service service;

    private LocalDateTime dateDemande = LocalDateTime.now();

    @Enumerated(EnumType.STRING)
    private StatutDemande statut;
}
