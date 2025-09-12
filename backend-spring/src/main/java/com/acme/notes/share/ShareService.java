package com.acme.notes.share;

import com.acme.notes.note.Note;
import com.acme.notes.note.NoteRepository;
import com.acme.notes.user.User;
import com.acme.notes.user.UserRepository;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class ShareService {

    private final ShareRepository repo;
    private final NoteRepository noteRepo;
    private final UserRepository userRepo;

    public ShareService(ShareRepository repo, NoteRepository noteRepo, UserRepository userRepo) {
        this.repo = repo;
        this.noteRepo = noteRepo;
        this.userRepo = userRepo;
    }

    public ShareDto createShare(Long noteId, String email, Permission permission) {
        Note note = noteRepo.findById(noteId).orElseThrow();
        User user = userRepo.findByEmail(email).orElseThrow();

        Share s = new Share();
        s.setNote(note);
        s.setUser(user);
        s.setPermission(permission);

        return ShareDto.from(repo.save(s));
    }

    public List<ShareDto> getShares(Long noteId) {
        Note note = noteRepo.findById(noteId).orElseThrow();
        return repo.findByNote(note).stream()
                .map(ShareDto::from)
                .toList();
    }

    public void deleteShare(Long noteId, Long shareId) {
        Note note = noteRepo.findById(noteId).orElseThrow();
        repo.findByIdAndNote(shareId, note).ifPresent(repo::delete);
    }
}