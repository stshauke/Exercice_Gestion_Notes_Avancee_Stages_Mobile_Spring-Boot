package com.acme.notes.share;

import com.acme.notes.note.Note;

import java.time.Instant;

public class ShareDto {
    private Long id;
    private Long noteId;
    private String noteTitle;
    private String noteContent;
    private String ownerEmail;
    private String permission;
    private Instant createdAt; // ✅ nouveau champ

    public static ShareDto from(Share s) {
        Note note = s.getNote();
        ShareDto dto = new ShareDto();
        dto.id = s.getId();
        dto.noteId = note.getId();
        dto.noteTitle = note.getTitle();
        dto.noteContent = note.getContentMd();
        dto.ownerEmail = note.getOwner().getEmail();
        dto.permission = s.getPermission().name();
        dto.createdAt = s.getCreatedAt(); // ✅ correction : utilise le getter de Share
        return dto;
    }

    // ---------- Getters / Setters ----------
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Long getNoteId() { return noteId; }
    public void setNoteId(Long noteId) { this.noteId = noteId; }

    public String getNoteTitle() { return noteTitle; }
    public void setNoteTitle(String noteTitle) { this.noteTitle = noteTitle; }

    public String getNoteContent() { return noteContent; }
    public void setNoteContent(String noteContent) { this.noteContent = noteContent; }

    public String getOwnerEmail() { return ownerEmail; }
    public void setOwnerEmail(String ownerEmail) { this.ownerEmail = ownerEmail; }

    public String getPermission() { return permission; }
    public void setPermission(String permission) { this.permission = permission; }

    public Instant getCreatedAt() { return createdAt; }  // ✅ getter
    public void setCreatedAt(Instant createdAt) { this.createdAt = createdAt; } // ✅ setter
}
