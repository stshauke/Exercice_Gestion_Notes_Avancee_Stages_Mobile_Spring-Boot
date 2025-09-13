package com.acme.notes.share;

import com.acme.notes.note.Note;

import java.time.Instant;

public record PublicShareDto(
        Long id,
        String urlToken,
        Long noteId,
        String noteTitle,
        String noteContent,
        Instant createdAt
) {
    public static PublicShareDto from(PublicShare ps) {
        Note note = ps.getNote();
        return new PublicShareDto(
                ps.getId(),
                ps.getUrlToken(),
                note.getId(),
                note.getTitle(),
                note.getContentMd(),
                ps.getCreatedAt()
        );
    }
}
