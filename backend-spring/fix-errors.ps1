# fix-errors.ps1
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
$projRoot = "C:\Users\tshau\dev\notes-suite\backend-spring"

function Fix-File($relPath, $transform) {
  $full = Join-Path $projRoot $relPath
  if (Test-Path $full) {
    $code = Get-Content $full -Raw
    $newCode = & $transform $code
    [IO.File]::WriteAllText($full,$newCode,$utf8NoBom)
    Write-Host "✅ Corrected $relPath"
  } else {
    Write-Host "❌ Fichier introuvable : $relPath"
  }
}

# --- Réécriture complète de NoteService.java ---
Fix-File "src\main\java\com\acme\notes\note\NoteService.java" {
@'
package com.acme.notes.note;

import com.acme.notes.user.User;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
public class NoteService {

    private final NoteRepository repo;

    public NoteService(NoteRepository repo) {
        this.repo = repo;
    }

    public List<Note> getNotes(User owner) {
        return repo.findByOwner(owner);
    }

    public Optional<Note> getNote(User owner, Long id) {
        return repo.findByIdAndOwner(id, owner);
    }

    public Note create(User owner, NoteCreateDto dto) {
        Note n = new Note();
        n.setTitle(dto.title());
        n.setContentMd(dto.contentMd());
        n.setOwner(owner);
        n.setVisibility(dto.visibility());
        return repo.save(n);
    }

    public Optional<Note> update(User owner, Long id, NoteUpdateDto dto) {
        return repo.findByIdAndOwner(id, owner).map(n -> {
            n.setTitle(dto.title());
            n.setContentMd(dto.contentMd());
            n.setVisibility(dto.visibility());
            return repo.save(n);
        });
    }

    public void delete(User owner, Long id) {
        repo.deleteByIdAndOwner(id, owner);
    }
}
'@
}

# --- Correction SecurityConfig.java (u.getRole() sans .name()) ---
Fix-File "src\main\java\com\acme\notes\security\SecurityConfig.java" {
  param($code)
  $code = $code -replace "u\.getRole\(\)\.name\(\)","u.getRole()"
  return $code
}

# --- Correction Share.java (ajout setter pour permission) ---
Fix-File "src\main\java\com\acme\notes\share\Share.java" {
  param($code)
  if ($code -notmatch "setPermission") {
    $code = $code -replace "(public Permission getPermission\(\)\s*\{[^\}]+\})",
@'
$1

    public void setPermission(Permission permission) {
        this.permission = permission;
    }
'@
  }
  return $code
}

Write-Host "🚀 Toutes les corrections ont été appliquées."
