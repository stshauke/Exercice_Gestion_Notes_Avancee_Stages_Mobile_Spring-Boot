// src/main/java/com/acme/notes/note/NoteService.java
package com.acme.notes.note;

import com.acme.notes.user.User;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class NoteService {

    private final NoteRepository repo;

    public NoteService(NoteRepository repo) {
        this.repo = repo;
    }

    public List<NoteDto> getNotes(User owner) {
        return repo.findByOwner(owner)
                .stream()
                .map(NoteDto::from)
                .collect(Collectors.toList());
    }

    public Optional<NoteDto> getNote(User owner, Long id) {
        return repo.findByIdAndOwner(id, owner).map(NoteDto::from);
    }

    public NoteDto create(User owner, NoteCreateDto dto) {
        Note n = new Note();
        n.setTitle(dto.title());
        n.setContentMd(dto.contentMd());
        n.setOwner(owner);

        // Visibilité par défaut si non fournie
        if (dto.visibility() == null) {
            n.setVisibility(Visibility.PRIVATE);
        } else {
            n.setVisibility(dto.visibility());
        }

        // Dates
        Instant now = Instant.now();
        n.setCreatedAt(now);
        n.setUpdatedAt(now);

        return NoteDto.from(repo.save(n));
    }

    public Optional<NoteDto> update(User owner, Long id, NoteUpdateDto dto) {
        return repo.findByIdAndOwner(id, owner).map(n -> {
            if (dto.hasTitle()) {
                n.setTitle(dto.title());
            }
            if (dto.hasContent()) {
                n.setContentMd(dto.contentMd());
            }
            if (dto.hasVisibility()) {
                n.setVisibility(dto.visibility());
            }

            // Mise à jour de la date
            n.setUpdatedAt(Instant.now());

            return NoteDto.from(repo.save(n));
        });
    }

   public void delete(User owner, Long id) {
    Note note = repo.findByIdAndOwner(id, owner)
        .orElseThrow(() -> new RuntimeException("Note introuvable ou non autorisée"));
    repo.delete(note);
}

}
