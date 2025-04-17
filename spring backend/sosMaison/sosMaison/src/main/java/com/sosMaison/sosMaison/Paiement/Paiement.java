package com.sosMaison.sosMaison.Paiement;

import com.sosMaison.sosMaison.Client.Client;
import com.sosMaison.sosMaison.Professional.Professional;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Paiement {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private double montant;

    @ManyToOne
    private Client client;

    @ManyToOne
    private Professional professionnel;

    @Enumerated(EnumType.STRING)
    private StatutPaiement statut;
}
