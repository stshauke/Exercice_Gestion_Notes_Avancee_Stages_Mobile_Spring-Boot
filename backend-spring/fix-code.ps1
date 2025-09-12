# fix-code.ps1
# Corrige le code backend pour correspondre au cahier des charges

Write-Host "🚀 Lancement des corrections..." -ForegroundColor Cyan

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

function WriteNoBom($path, $content) {
  $full = Resolve-Path $path
  if (-not (Test-Path $full)) {
    Write-Host "⚠️  Fichier introuvable : $path" -ForegroundColor Yellow
    return
  }
  Copy-Item $full "$full.bak" -Force
  [IO.File]::WriteAllText($full, $content, $utf8NoBom)
  Write-Host "✅ Corrigé : $path" -ForegroundColor Green
}

# ---- Note.java ----
$notePath = "src\main\java\com\acme\notes\note\Note.java"
$noteCode = @'
package com.acme.notes.note;

import com.acme.notes.user.User;
import jakarta.persistence.*;
import java.time.Instant;

@Entity
@Table(name = "notes")
public class Note {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long id;

  @Column(nullable = false)
  private String title;

  @Column(nullable = false, columnDefinition = "text")
  private String contentMd;

  @Column(nullable = false, updatable = false)
  private Instant createdAt;

  @Column(nullable = false)
  private Instant updatedAt;

  @ManyToOne(optional = false)
  @JoinColumn(name = "owner_id")
  private User owner;

  @Enumerated(EnumType.STRING)
  @Column(nullable = false, length = 20)
  private Visibility visibility = Visibility.PRIVATE;

  public Note() {}

  // Getters / Setters
  public Long getId() { return id; }
  public void setId(Long id) { this.id = id; }

  public String getTitle() { return title; }
  public void setTitle(String title) { this.title = title; }

  public String getContentMd() { return contentMd; }
  public void setContentMd(String contentMd) { this.contentMd = contentMd; }

  public Instant getCreatedAt() { return createdAt; }
  public void setCreatedAt(Instant createdAt) { this.createdAt = createdAt; }

  public Instant getUpdatedAt() { return updatedAt; }
  public void setUpdatedAt(Instant updatedAt) { this.updatedAt = updatedAt; }

  public User getOwner() { return owner; }
  public void setOwner(User owner) { this.owner = owner; }

  public Visibility getVisibility() { return visibility; }
  public void setVisibility(Visibility visibility) { this.visibility = visibility; }
}
'@
WriteNoBom $notePath $noteCode

# ---- NoteRepository.java ----
$repoPath = "src\main\java\com\acme\notes\note\NoteRepository.java"
$repoCode = @'
package com.acme.notes.note;

import com.acme.notes.user.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

@Repository
public interface NoteRepository extends JpaRepository<Note, Long> {
    List<Note> findByOwner(User owner);
    Optional<Note> findByIdAndOwner(Long id, User owner);
    void deleteByIdAndOwner(Long id, User owner);
}
'@
WriteNoBom $repoPath $repoCode

# ---- NoteCreateDto.java ----
$createDtoPath = "src\main\java\com\acme\notes\note\NoteCreateDto.java"
$createDtoCode = @'
package com.acme.notes.note;

public record NoteCreateDto(String title, String contentMd) {}
'@
WriteNoBom $createDtoPath $createDtoCode

# ---- NoteUpdateDto.java ----
$updateDtoPath = "src\main\java\com\acme\notes\note\NoteUpdateDto.java"
$updateDtoCode = @'
package com.acme.notes.note;

public record NoteUpdateDto(String title, String contentMd) {}
'@
WriteNoBom $updateDtoPath $updateDtoCode

# ---- NoteService.java ----
$svcPath = "src\main\java\com\acme\notes\note\NoteService.java"
$svcCode = @'
package com.acme.notes.note;

import com.acme.notes.user.User;
import com.acme.notes.user.UserRepository;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.List;

@Service
public class NoteService {

  private final NoteRepository repo;
  private final UserRepository users;

  public NoteService(NoteRepository repo, UserRepository users) {
    this.repo = repo;
    this.users = users;
  }

  public List<NoteViewDto> list() {
    return java.util.Collections.emptyList();
  }

  public List<NoteViewDto> listFor(String email) {
    var u = users.findByEmail(email).orElseThrow();
    return repo.findByOwner(u).stream().map(NoteViewDto::from).toList();
  }

  public NoteViewDto create(String email, NoteCreateDto dto) {
    var u = users.findByEmail(email).orElseThrow();
    Note n = new Note();
    n.setTitle(dto.title());
    n.setContentMd(dto.contentMd());
    n.setOwner(u);
    n.setVisibility(Visibility.PRIVATE);
    Instant now = Instant.now();
    n.setCreatedAt(now);
    n.setUpdatedAt(now);
    n = repo.save(n);
    return NoteViewDto.from(n);
  }

  public NoteViewDto update(String email, Long id, NoteUpdateDto dto) {
    var u = users.findByEmail(email).orElseThrow();
    Note n = repo.findByIdAndOwner(id, u).orElseThrow();
    if (dto.title() != null && !dto.title().isBlank()) {
      n.setTitle(dto.title());
    }
    if (dto.contentMd() != null && !dto.contentMd().isBlank()) {
      n.setContentMd(dto.contentMd());
    }
    n.setUpdatedAt(Instant.now());
    n = repo.save(n);
    return NoteViewDto.from(n);
  }

  public void delete(String email, Long id) {
    var u = users.findByEmail(email).orElseThrow();
    if (!repo.existsById(id)) throw new ResponseStatusException(HttpStatus.NOT_FOUND);
    repo.deleteByIdAndOwner(id, u);
  }
}
'@
WriteNoBom $svcPath $svcCode

# ---- User.java ----
$userPath = "src\main\java\com\acme\notes\user\User.java"
$userCode = @'
package com.acme.notes.user;

import jakarta.persistence.*;
import lombok.*;

import java.time.Instant;

@Entity
@Table(name = "users")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class User {
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long id;

  @Column(nullable = false, unique = true)
  private String email;

  @Column(nullable = false, name = "password_hash")
  private String passwordHash;

  @Column(nullable = false, updatable = false)
  private Instant createdAt;

  @Enumerated(EnumType.STRING)
  @Column(nullable = false)
  private Role role;
}
'@
WriteNoBom $userPath $userCode

# ---- ShareController.java ----
$shcPath = "src\main\java\com\acme\notes\share\ShareController.java"
$shcCode = @'
package com.acme.notes.share;

import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/shares")
public class ShareController {

  private final ShareService service;

  public ShareController(ShareService service) {
    this.service = service;
  }

  @GetMapping("/{noteId}")
  public List<ShareDto> list(@AuthenticationPrincipal UserDetails me,
                             @PathVariable Long noteId) {
    return service.listShares(me.getUsername(), noteId);
  }

  @PostMapping("/{noteId}")
  public ResponseEntity<ShareDto> create(@AuthenticationPrincipal UserDetails me,
                                         @PathVariable Long noteId,
                                         @RequestParam String email) {
    var dto = service.createShare(me.getUsername(), noteId, email, Permission.READ);
    return ResponseEntity.ok(dto);
  }

  @DeleteMapping("/{noteId}/{shareId}")
  public ResponseEntity<Void> delete(@AuthenticationPrincipal UserDetails me,
                                     @PathVariable Long noteId,
                                     @PathVariable Long shareId) {
    service.deleteShare(me.getUsername(), noteId, shareId);
    return ResponseEntity.noContent().build();
  }
}
'@
WriteNoBom $shcPath $shcCode

# ---- ShareService.java ----
$shsPath = "src\main\java\com\acme\notes\share\ShareService.java"
$shsCode = @'
package com.acme.notes.share;

import com.acme.notes.note.NoteRepository;
import com.acme.notes.user.UserRepository;
import com.acme.notes.user.User;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;

@Service
public class ShareService {

  private final ShareRepository repo;
  private final NoteRepository notes;
  private final UserRepository users;

  public ShareService(ShareRepository repo, NoteRepository notes, UserRepository users) {
    this.repo = repo;
    this.notes = notes;
    this.users = users;
  }

  public List<ShareDto> listShares(String email, Long noteId) {
    var owner = users.findByEmail(email).orElseThrow();
    var note = notes.findByIdAndOwner(noteId, owner).orElseThrow();
    return repo.findByNote(note).stream().map(ShareDto::from).toList();
  }

  public ShareDto createShare(String email, Long noteId, String targetEmail, Permission permission) {
    var owner = users.findByEmail(email).orElseThrow();
    var note = notes.findByIdAndOwner(noteId, owner).orElseThrow();
    var target = users.findByEmail(targetEmail).orElseThrow();
    Share s = new Share(note, target);
    s.setPermission(permission);
    s = repo.save(s);
    return ShareDto.from(s);
  }

  public void deleteShare(String email, Long noteId, Long shareId) {
    var owner = users.findByEmail(email).orElseThrow();
    var note = notes.findByIdAndOwner(noteId, owner).orElseThrow();
    var s = repo.findByIdAndNote(shareId, note).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND));
    repo.delete(s);
  }
}
'@
WriteNoBom $shsPath $shsCode

Write-Host "🎉 Toutes les corrections (Note, User, Share, etc.) appliquées !" -ForegroundColor Cyan
