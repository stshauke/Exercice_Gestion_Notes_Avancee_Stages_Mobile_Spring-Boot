// src/main/java/com/acme/notes/note/NoteDto.java
package com.acme.notes.note;

import java.time.Instant;

public record NoteDto(
    Long id,
    String title,
    String contentMd,
    String ownerEmail,
    Visibility visibility,
    Instant createdAt,
    Instant updatedAt
) {
    public static NoteDto from(Note note) {
        return new NoteDto(
            note.getId(),
            note.getTitle(),
            note.getContentMd(),
            note.getOwner() != null ? note.getOwner().getEmail() : null,
            note.getVisibility(),
            note.getCreatedAt(),
            note.getUpdatedAt()
        );
    }
}
