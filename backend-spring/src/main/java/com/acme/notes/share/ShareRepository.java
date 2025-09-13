package com.acme.notes.share;

import com.acme.notes.note.Note;
import com.acme.notes.user.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface ShareRepository extends JpaRepository<Share, Long> {

    // Trouver tous les partages d'une note
    List<Share> findByNote(Note note);

    // Trouver tous les partages pour un utilisateur
    List<Share> findByUser(User user);

    // Trouver un partage précis par son id et la note associée
    Optional<Share> findByIdAndNote(Long id, Note note);
}
