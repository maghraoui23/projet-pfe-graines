package com.sosMaison.sosMaison.Client;

import com.sosMaison.sosMaison.Evaluation.Evaluation;
import com.sosMaison.sosMaison.Services.DemandeService;
import com.sosMaison.sosMaison.User.User;
import jakarta.persistence.*;
import lombok.*;
import org.springframework.boot.autoconfigure.security.SecurityProperties;

import java.util.List;
@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Client extends User {
    @OneToMany(mappedBy = "client")
    private List<DemandeService> demandes;


}
