package com.acme.notes.share;

import com.acme.notes.note.Note;
import jakarta.persistence.*;
import java.time.Instant;

@Entity
@Table(name = "public_shares")
public class PublicShare {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(optional = false)
    @JoinColumn(name = "note_id")
    private Note note;

    @Column(nullable = false, unique = true)
    private String urlToken;

    @Column(nullable = false, updatable = false)
    private Instant createdAt = Instant.now();

    // --- Getters/Setters ---
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Note getNote() { return note; }
    public void setNote(Note note) { this.note = note; }

    public String getUrlToken() { return urlToken; }
    public void setUrlToken(String urlToken) { this.urlToken = urlToken; }

    public Instant getCreatedAt() { return createdAt; }
    public void setCreatedAt(Instant createdAt) { this.createdAt = createdAt; }
}
