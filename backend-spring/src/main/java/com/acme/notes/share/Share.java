package com.acme.notes.share;

import com.acme.notes.note.Note;
import com.acme.notes.user.User;
import jakarta.persistence.*;
import java.time.Instant;

@Entity
public class Share {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(optional = false)
    private Note note;

    @ManyToOne(optional = false)
    private User user;

    @Enumerated(EnumType.STRING)
    private Permission permission;

    @Column(nullable = false, updatable = false)
    private Instant createdAt = Instant.now(); // ✅ ajouté

    // --- Getters & setters ---
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Note getNote() {
        return note;
    }

    public void setNote(Note note) {
        this.note = note;
    }

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }

    public Permission getPermission() {
        return permission;
    }

    public void setPermission(Permission permission) {
        this.permission = permission;
    }

    public Instant getCreatedAt() {   // ✅ ajouté
        return createdAt;
    }

    public void setCreatedAt(Instant createdAt) { // ✅ si besoin
        this.createdAt = createdAt;
    }
}
