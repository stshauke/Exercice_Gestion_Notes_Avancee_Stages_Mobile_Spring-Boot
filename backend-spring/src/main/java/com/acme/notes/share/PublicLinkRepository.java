package com.acme.notes.share;

import com.acme.notes.note.Note;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface PublicLinkRepository extends JpaRepository<PublicLink, Long> {
    Optional<PublicLink> findByUrlToken(String urlToken);
    void deleteByNote(Note note);
}