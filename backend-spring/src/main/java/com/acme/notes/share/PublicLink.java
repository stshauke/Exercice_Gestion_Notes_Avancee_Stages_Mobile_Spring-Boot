package com.acme.notes.share;

import com.acme.notes.note.Note;
import jakarta.persistence.*;
import java.time.Instant;

@Entity
@Table(name = "public_links")
public class PublicLink {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(optional = false)
    @JoinColumn(name = "note_id")
    private Note note;

    @Column(nullable = false, unique = true, length = 64)
    private String urlToken;

    private Instant expiresAt; // optionnel

    public PublicLink() {}
    public PublicLink(Note note, String urlToken, Instant expiresAt) {
        this.note = note;
        this.urlToken = urlToken;
        this.expiresAt = expiresAt;
    }

    public Long getId() { return id; }
    public Note getNote() { return note; }
    public String getUrlToken() { return urlToken; }
    public Instant getExpiresAt() { return expiresAt; }
}