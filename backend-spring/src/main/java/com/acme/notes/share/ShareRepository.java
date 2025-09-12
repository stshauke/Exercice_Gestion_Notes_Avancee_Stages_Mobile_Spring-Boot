package com.acme.notes.share;

import com.acme.notes.note.Note;
import com.acme.notes.user.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface ShareRepository extends JpaRepository<Share, Long> {
    Optional<Share> findByIdAndNote(Long id, Note note);
    List<Share> findByUser(User user);
    List<Share> findByNote(Note note);
}
