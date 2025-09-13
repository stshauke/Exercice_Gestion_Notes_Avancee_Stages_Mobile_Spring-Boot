package com.acme.notes.share;

import com.acme.notes.note.Note;
import com.acme.notes.note.NoteRepository;
import com.acme.notes.user.User;
import com.acme.notes.user.UserRepository;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class ShareService {

    private final ShareRepository shareRepository;
    private final PublicShareRepository publicShareRepository;
    private final NoteRepository noteRepository;
    private final UserRepository userRepository;

    public ShareService(ShareRepository shareRepository,
                        PublicShareRepository publicShareRepository,
                        NoteRepository noteRepository,
                        UserRepository userRepository) {
        this.shareRepository = shareRepository;
        this.publicShareRepository = publicShareRepository;
        this.noteRepository = noteRepository;
        this.userRepository = userRepository;
    }

    // ---------- Partages privés ----------
    public ShareDto createShare(Long noteId, String email, Permission permission) {
        Note note = noteRepository.findById(noteId)
                .orElseThrow(() -> new RuntimeException("Note introuvable"));

        User target = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé"));

        Share share = new Share();
        share.setNote(note);
        share.setUser(target);
        share.setPermission(permission);
        share.setCreatedAt(Instant.now()); // ✅ ajout du champ createdAt dans Share

        return ShareDto.from(shareRepository.save(share));
    }

    public List<ShareDto> getShares(Long noteId) {
        Note note = noteRepository.findById(noteId)
                .orElseThrow(() -> new RuntimeException("Note introuvable"));
        return shareRepository.findByNote(note).stream()
                .map(ShareDto::from)
                .toList();
    }

    public void deleteShare(Long noteId, Long shareId) {
        Note note = noteRepository.findById(noteId)
                .orElseThrow(() -> new RuntimeException("Note introuvable"));

        Share share = shareRepository.findByIdAndNote(shareId, note)
                .orElseThrow(() -> new RuntimeException("Partage introuvable"));

        shareRepository.delete(share);
    }

    public List<ShareDto> getSharesForUser(User user) {
        return shareRepository.findByUser(user).stream()
                .map(ShareDto::from)
                .toList();
    }

    // ---------- Partages publics ----------
    public PublicShareDto createPublicShare(User user, Long noteId) {
        Note note = noteRepository.findById(noteId)
                .orElseThrow(() -> new RuntimeException("Note introuvable"));

        PublicShare ps = new PublicShare();
        ps.setNote(note);
        ps.setUrlToken(UUID.randomUUID().toString());
        ps.setCreatedAt(Instant.now());

        return PublicShareDto.from(publicShareRepository.save(ps));
    }

    public PublicShareDto getPublicShare(String token) {
        PublicShare ps = publicShareRepository.findByUrlToken(token)
                .orElseThrow(() -> new RuntimeException("Lien public introuvable"));

        return PublicShareDto.from(ps);
    }

    // ---------- Récupérer tous les partages (privés + publics) accessibles par un user ----------
public List<PublicShareDto> getAllSharesForUser(User user) {
    // Partages privés reçus
    List<PublicShareDto> privateShares = shareRepository.findByUser(user).stream()
            .map(ShareDto::from)
            .map(shareDto -> new PublicShareDto(
                    shareDto.getId(),
                    null, // pas de token pour un partage privé
                    shareDto.getNoteId(),
                    shareDto.getNoteTitle(),
                    shareDto.getNoteContent(),
                    null // pas de createdAt dans ShareDto, donc on met null ou à adapter
            ))
            .collect(Collectors.toList());

    // Partages publics (accessibles par tous)
    List<PublicShareDto> publicShares = publicShareRepository.findAll().stream()
            .map(PublicShareDto::from)
            .toList();

    // Fusionner les deux listes
    privateShares.addAll(publicShares);
    return privateShares;
}

}
