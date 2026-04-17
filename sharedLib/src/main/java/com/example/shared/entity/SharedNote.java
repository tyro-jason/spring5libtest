package com.example.shared.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

/**
 * Shared JPA entity written against Jakarta APIs.
 * Eclipse Transformer converts this to javax.persistence for Spring 5 consumers.
 */
@Entity
@Table(name = "shared_note")
public class SharedNote {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 255)
    private String message;

    protected SharedNote() {
        // Required by JPA
    }

    public SharedNote(String message) {
        this.message = message;
    }

    public Long getId() {
        return id;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }
}

