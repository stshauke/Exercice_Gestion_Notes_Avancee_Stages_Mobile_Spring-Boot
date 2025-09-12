package com.acme.notes.note;

import com.acme.notes.user.User;
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
  private String contentMd;

  @Column(nullable = false, updatable = false)
  private Instant createdAt;

  @Column(nullable = false)
  private Instant updatedAt;

  @ManyToOne(optional = false)
  @JoinColumn(name = "owner_id")
  private User owner;

  @Enumerated(EnumType.STRING)
  @Column(nullable = false, length = 20)
  private Visibility visibility = Visibility.PRIVATE;

  public Note() {}

  // --- Getters / Setters ---
  public Long getId() { return id; }
  public void setId(Long id) { this.id = id; }

  public String getTitle() { return title; }
  public void setTitle(String title) { this.title = title; }

  public String getContentMd() { return contentMd; }
  public void setContentMd(String contentMd) { this.contentMd = contentMd; }

  public Instant getCreatedAt() { return createdAt; }
  public void setCreatedAt(Instant createdAt) { this.createdAt = createdAt; }

  public Instant getUpdatedAt() { return updatedAt; }
  public void setUpdatedAt(Instant updatedAt) { this.updatedAt = updatedAt; }

  public User getOwner() { return owner; }
  public void setOwner(User owner) { this.owner = owner; }

  public Visibility getVisibility() { return visibility; }
  public void setVisibility(Visibility visibility) { this.visibility = visibility; }
}
