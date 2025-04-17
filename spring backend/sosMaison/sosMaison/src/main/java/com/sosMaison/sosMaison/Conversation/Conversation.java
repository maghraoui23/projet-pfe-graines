package com.sosMaison.sosMaison.Conversation;


import com.sosMaison.sosMaison.Message.Message;
import com.sosMaison.sosMaison.User.User;
import jakarta.persistence.*;

import java.util.ArrayList;
import java.util.List;

@Entity
public class Conversation {

    @Id
    @GeneratedValue
    private Long id;

    @ManyToOne
    private User auteur;

    @ManyToOne
    private User recepteur;

    @OneToMany(mappedBy = "conversation", cascade = CascadeType.ALL, orphanRemoval = true)
    List<Message> messages=new ArrayList<>();


    public Conversation() {
    }

    public Conversation(User auteur, User recepteur) {

        this.auteur = auteur;
        this.recepteur = recepteur;

    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public User getAuteur() {
        return auteur;
    }

    public void setAuteur(User auteur) {
        this.auteur = auteur;
    }

    public User getRecepteur() {
        return recepteur;
    }

    public void setRecepteur(User recepteur) {
        this.recepteur = recepteur;
    }

    public List<Message> getMessages() {
        return messages;
    }

    public void setMessages(List<Message> messages) {
        this.messages = messages;
    }
}
