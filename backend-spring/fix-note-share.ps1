# fix-note-share.ps1
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
$projRoot = "C:\Users\tshau\dev\notes-suite\backend-spring"

function WriteNoBom($path,$content) {
  $full = Join-Path $projRoot $path
  $dir = Split-Path $full
  if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
  if (Test-Path $full) { Copy-Item $full "$full.bak" -Force }
  [IO.File]::WriteAllText($full,$content,$utf8NoBom)
  Write-Host "✅ Wrote: $full"
}

# --- NoteController.java ---
$noteControllerCode = @'
package com.acme.notes.note;

import com.acme.notes.user.User;
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
    public List<NoteDto> listNotes(@AuthenticationPrincipal User user) {
        return service.getNotes(user);
    }

    @PostMapping
    public NoteDto createNote(@AuthenticationPrincipal User user, @RequestBody NoteCreateDto dto) {
        return service.create(user, dto);
    }

    @GetMapping("/{id}")
    public NoteDto getNote(@AuthenticationPrincipal User user, @PathVariable Long id) {
        return service.getNote(user, id);
    }

    @PutMapping("/{id}")
    public NoteDto updateNote(@AuthenticationPrincipal User user, @PathVariable Long id, @RequestBody NoteUpdateDto dto) {
        return service.update(user, id, dto);
    }

    @DeleteMapping("/{id}")
    public void deleteNote(@AuthenticationPrincipal User user, @PathVariable Long id) {
        service.delete(user, id);
    }
}
'@
WriteNoBom "src\main\java\com\acme\notes\note\NoteController.java" $noteControllerCode

# --- ShareService.java ---
$shareServiceCode = @'
package com.acme.notes.share;

import com.acme.notes.note.Note;
import com.acme.notes.note.NoteRepository;
import com.acme.notes.user.User;
import com.acme.notes.user.UserRepository;
import org.springframework.stereotype.Service;

import java.util.List;

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

    public ShareDto createShare(Long noteId, String email, Permission permission, User owner) {
        Note note = noteRepo.findByIdAndOwner(noteId, owner).orElseThrow();
        User target = userRepo.findByEmail(email).orElseThrow();

        Share s = new Share(note, target);
        s.setPermission(permission);

        return ShareDto.from(repo.save(s));
    }

    public List<ShareDto> listShares(Long noteId, User owner) {
        Note note = noteRepo.findByIdAndOwner(noteId, owner).orElseThrow();
        return repo.findByNote(note).stream()
                .map(ShareDto::from)
                .toList();
    }

    public void deleteShare(Long noteId, Long shareId, User owner) {
        Note note = noteRepo.findByIdAndOwner(noteId, owner).orElseThrow();
        Share s = repo.findByIdAndNote(shareId, note).orElseThrow();
        repo.delete(s);
    }
}
'@
WriteNoBom "src\main\java\com\acme\notes\share\ShareService.java" $shareServiceCode
