package com.sosMaison.sosMaison.Conversation;


import com.sosMaison.sosMaison.AuthService.Userservice;
import com.sosMaison.sosMaison.Message.Message;
import com.sosMaison.sosMaison.Message.MessageRepository;
import com.sosMaison.sosMaison.User.User;
import jakarta.transaction.Transactional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class ChatService {

    @Autowired
    private ConversationRepository conversationRepository;

    @Autowired
    private MessageRepository messageRepository;

    @Autowired
    private Userservice userService;

    public ChatService(ConversationRepository conversationRepository, MessageRepository messageRepository) {
        this.conversationRepository = conversationRepository;
        this.messageRepository = messageRepository;
    }

    public List<Conversation> getConversationsOfUsers(User user) {
        return conversationRepository.findByAuteurOrRecepteur(user, user);
    }
    public Conversation getconversation(User user,Long conversationId){
        Conversation conversation = conversationRepository.findById(conversationId)
                .orElseThrow(() -> new RuntimeException("conversation not found"));
        if(!conversation.getAuteur().getId().equals(user.getId()) && !conversation.getRecepteur().getId().equals(user.getId())) {
            throw new RuntimeException("conversation does not belong to user");
        }
        return conversation;


    }
    @Transactional
    public Conversation createConversationAndAddMessage(User sender, Long receiverId, String content) {
        User receiver = userService.getUserById(receiverId);

        conversationRepository.findByAuteurAndRecepteur(sender, receiver).ifPresentOrElse(
                conversation -> {
                    throw new IllegalArgumentException(
                            "Conversation already exists, use the conversation id to send messages.");
                },
                () -> {
                });

        conversationRepository.findByAuteurAndRecepteur(receiver, sender).ifPresentOrElse(
                conversation -> {
                    throw new IllegalArgumentException(
                            "Conversation already exists, use the conversation id to send messages.");
                },
                () -> {
                });

        Conversation conversation = conversationRepository.save(new Conversation(sender, receiver));
        Message message = new Message(sender, receiver, conversation, content);
        messageRepository.save(message);
        conversation.getMessages().add(message);

        return conversation;
    }

    public Message addMessageToConversation(Long conversationId, User sender, Long receiverId, String content) {
        User receiver = userService.getUserById(receiverId);
        Conversation conversation = conversationRepository.findById(conversationId)
                .orElseThrow(() -> new IllegalArgumentException("Conversation not found"));

        if (!conversation.getAuteur().getId().equals(sender.getId())
                && !conversation.getRecepteur().getId().equals(sender.getId())) {
            throw new IllegalArgumentException("User not authorized to send message to this conversation");
        }

        if (!conversation.getAuteur().getId().equals(receiver.getId())
                && !conversation.getRecepteur().getId().equals(receiver.getId())) {
            throw new IllegalArgumentException("Receiver is not part of this conversation");
        }

        Message message = new Message(sender, receiver, conversation, content);
        messageRepository.save(message);
        conversation.getMessages().add(message);

        return message;
    }
    public void markMessageAsRead(User user, Long messageId) {
        Message message = messageRepository.findById(messageId)
                .orElseThrow(() -> new IllegalArgumentException("Message not found"));

        if (!message.getReceiver().getId().equals(user.getId())) {
            throw new IllegalArgumentException("User not authorized to mark message as read");
        }

        if (!message.isVu()) {
            message.setVu(true);
            messageRepository.save(message);

        }
    }
}
