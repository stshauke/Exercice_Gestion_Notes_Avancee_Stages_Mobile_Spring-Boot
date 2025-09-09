package com.acme.notes.note;

import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;

public interface NoteRepository extends JpaRepository<Note, Long> {
  List<Note> findByOwnerEmail(String ownerEmail);
  Optional<Note> findByIdAndOwnerEmail(Long id, String ownerEmail);
  void deleteByIdAndOwnerEmail(Long id, String ownerEmail);
}