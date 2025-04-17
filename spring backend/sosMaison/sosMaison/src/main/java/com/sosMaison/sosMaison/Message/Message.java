package com.sosMaison.sosMaison.Message;


import com.fasterxml.jackson.annotation.JsonIgnore;
import com.sosMaison.sosMaison.Conversation.Conversation;
import com.sosMaison.sosMaison.User.User;
import jakarta.persistence.*;
import lombok.Getter;
import org.springframework.boot.autoconfigure.web.WebProperties;

import java.time.LocalDateTime;


@Entity
public class Message {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(optional = false)
    private User Sender;

    @ManyToOne(optional = false)
    private User Receiver;

    @JsonIgnore
    @ManyToOne(optional = false)
    private Conversation conversation;

    private String message;
    private boolean Vu;

    private LocalDateTime message_time = LocalDateTime.now();


    public Message() {
    }

    public Message(User sender, User receiver, Conversation conversation, String message) {

        Sender = sender;
        Receiver = receiver;
        this.conversation = conversation;
        this.message = message;


    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public User getSender() {
        return Sender;
    }

    public void setSender(User sender) {
        Sender = sender;
    }

    public User getReceiver() {
        return Receiver;
    }

    public void setReceiver(User receiver) {
        Receiver = receiver;
    }

    public Conversation getConversation() {
        return conversation;
    }

    public void setConversation(Conversation conversation) {
        this.conversation = conversation;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public boolean isVu() {
        return Vu;
    }

    public void setVu(boolean vu) {
        Vu = vu;
    }

    public LocalDateTime getMessage_time() {
        return message_time;
    }

    public void setMessage_time(LocalDateTime message_time) {
        this.message_time = message_time;
    }
}
