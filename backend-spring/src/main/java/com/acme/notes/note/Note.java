package com.acme.notes.note;

import jakarta.persistence.*;
import java.time.Instant;

@Entity
@Table(name = "notes")
public class Note {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long id;

  @Column(nullable = false)
  private String title;

  @Column(nullable = false, columnDefinition = "text")
  private String content;

  @Column(nullable = false, updatable = false)
  private Instant createdAt;

  @Column(nullable = false)
  private Instant updatedAt;

  // <-- le fameux champ attendu par le Repository
  @Column(nullable = false, length = 255)
  private String ownerEmail;

  public Note() {}

  // Getters / Setters
  public Long getId() { return id; }
  public void setId(Long id) { this.id = id; }

  public String getTitle() { return title; }
  public void setTitle(String title) { this.title = title; }

  public String getContent() { return content; }
  public void setContent(String content) { this.content = content; }

  public Instant getCreatedAt() { return createdAt; }
  public void setCreatedAt(Instant createdAt) { this.createdAt = createdAt; }

  public Instant getUpdatedAt() { return updatedAt; }
  public void setUpdatedAt(Instant updatedAt) { this.updatedAt = updatedAt; }

  public String getOwnerEmail() { return ownerEmail; }
  public void setOwnerEmail(String ownerEmail) { this.ownerEmail = ownerEmail; }
}