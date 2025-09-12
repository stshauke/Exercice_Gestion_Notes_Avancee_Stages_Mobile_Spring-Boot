# fix-controllers.ps1
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
$projRoot = "C:\Users\tshau\dev\notes-suite\backend-spring"

function Fix-File($relPath,$content) {
  $full = Join-Path $projRoot $relPath
  if (!(Test-Path $full)) {
    Write-Host "❌ Fichier introuvable : $relPath"
    return
  }
  [IO.File]::WriteAllText($full,$content,$utf8NoBom)
  Write-Host "✅ Réécrit $relPath"
}

# --- Réécriture complète de NoteService.java ---
$noteServiceCode = @'
package com.acme.notes.note;

import com.acme.notes.user.User;
import org.springframework.stereotype.Service;
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
        n.setVisibility(dto.visibility());
        return NoteDto.from(repo.save(n));
    }

    public Optional<NoteDto> update(User owner, Long id, NoteUpdateDto dto) {
        return repo.findByIdAndOwner(id, owner).map(n -> {
            n.setTitle(dto.title());
            n.setContentMd(dto.contentMd());
            n.setVisibility(dto.visibility());
            return NoteDto.from(repo.save(n));
        });
    }

    public void delete(User owner, Long id) {
        repo.deleteByIdAndOwner(id, owner);
    }
}
'@
Fix-File "src\main\java\com\acme\notes\note\NoteService.java" $noteServiceCode

# --- Réécriture complète de NoteController.java ---
$noteControllerCode = @'
package com.acme.notes.note;

import com.acme.notes.user.User;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/notes")
public class NoteController {

    private final NoteService service;

    public NoteController(NoteService service) {
        this.service = service;
    }

    @GetMapping
    public List<NoteDto> all(@AuthenticationPrincipal User user) {
        return service.getNotes(user);
    }

    @PostMapping
    public NoteDto create(@AuthenticationPrincipal User user, @RequestBody NoteCreateDto dto) {
        return service.create(user, dto);
    }

    @GetMapping("/{id}")
    public ResponseEntity<NoteDto> one(@AuthenticationPrincipal User user, @PathVariable Long id) {
        return service.getNote(user, id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PutMapping("/{id}")
    public ResponseEntity<NoteDto> update(@AuthenticationPrincipal User user, @PathVariable Long id, @RequestBody NoteUpdateDto dto) {
        return service.update(user, id, dto)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@AuthenticationPrincipal User user, @PathVariable Long id) {
        service.delete(user, id);
        return ResponseEntity.noContent().build();
    }
}
'@
Fix-File "src\main\java\com\acme\notes\note\NoteController.java" $noteControllerCode

# --- Réécriture complète de ShareDto.java ---
$shareDtoCode = @'
package com.acme.notes.share;

import com.acme.notes.user.User;

public record ShareDto(Long id, Long noteId, String sharedWith, Permission permission) {

    public static ShareDto from(Share share) {
        return new ShareDto(
                share.getId(),
                share.getNote().getId(),
                share.getUser().getEmail(),
                share.getPermission()
        );
    }
}
'@
Fix-File "src\main\java\com\acme\notes\share\ShareDto.java" $shareDtoCode

# --- Réécriture complète de ShareService.java ---
$shareServiceCode = @'
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
'@
Fix-File "src\main\java\com\acme\notes\share\ShareService.java" $shareServiceCode

# --- Réécriture complète de ShareController.java ---
$shareControllerCode = @'
package com.acme.notes.share;

import com.acme.notes.user.User;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/notes/{noteId}/shares")
public class ShareController {

    private final ShareService service;

    public ShareController(ShareService service) {
        this.service = service;
    }

    @PostMapping
    public ShareDto create(@AuthenticationPrincipal User user,
                           @PathVariable Long noteId,
                           @RequestParam String email,
                           @RequestParam Permission permission) {
        return service.createShare(noteId, email, permission);
    }

    @GetMapping
    public List<ShareDto> list(@AuthenticationPrincipal User user,
                               @PathVariable Long noteId) {
        return service.getShares(noteId);
    }

    @DeleteMapping("/{shareId}")
    public ResponseEntity<Void> delete(@AuthenticationPrincipal User user,
                                       @PathVariable Long noteId,
                                       @PathVariable Long shareId) {
        service.deleteShare(noteId, shareId);
        return ResponseEntity.noContent().build();
    }
}
'@
Fix-File "src\main\java\com\acme\notes\share\ShareController.java" $shareControllerCode

Write-Host "🚀 Corrections appliquées (NoteService, NoteController, ShareDto, ShareService, ShareController)."
