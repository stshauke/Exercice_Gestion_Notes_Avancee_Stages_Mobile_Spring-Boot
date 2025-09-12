package com.acme.notes.share;

import com.acme.notes.note.Note;
import com.acme.notes.note.NoteRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.security.SecureRandom;
import java.time.Instant;
import java.util.Base64;

@Service
public class PublicLinkService {

    private final PublicLinkRepository repo;
    private final NoteRepository notes;
    private final SecureRandom random = new SecureRandom();

    public PublicLinkService(PublicLinkRepository repo, NoteRepository notes) {
        this.repo = repo;
        this.notes = notes;
    }

    public PublicLink createLink(Long noteId, String ownerEmail) {
        Note note = notes.findById(noteId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND));
        if (!note.getOwner().equals(ownerEmail)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN);
        }
        String token = generateToken();
        PublicLink pl = new PublicLink(note, token, null);
        return repo.save(pl);
    }

    public Note getNoteByToken(String token) {
        PublicLink pl = repo.findByUrlToken(token)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND));
        if (pl.getExpiresAt() != null && pl.getExpiresAt().isBefore(Instant.now())) {
            throw new ResponseStatusException(HttpStatus.GONE);
        }
        return pl.getNote();
    }

    private String generateToken() {
        byte[] bytes = new byte[24];
        random.nextBytes(bytes);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
    }
}