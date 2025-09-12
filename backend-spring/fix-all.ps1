# fix-all.ps1
# Encodage UTF-8 sans BOM
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
$projRoot = "C:\Users\tshau\dev\notes-suite\backend-spring"

function WriteNoBom($relPath,$content) {
  $full = Join-Path $projRoot $relPath
  $dir = Split-Path $full
  if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
  if (Test-Path $full) { Copy-Item $full "$full.bak" -Force }
  [IO.File]::WriteAllText($full,$content,$utf8NoBom)
  Write-Host "✅ Wrote: $full"
}

# --- NoteDto.java ---
$noteDtoCode = @'
package com.acme.notes.note;

public record NoteDto(
    Long id,
    String title,
    String contentMd,
    String ownerEmail,
    Visibility visibility
) {
    public static NoteDto from(Note note) {
        return new NoteDto(
            note.getId(),
            note.getTitle(),
            note.getContentMd(),
            note.getOwner() != null ? note.getOwner().getEmail() : null,
            note.getVisibility()
        );
    }
}
'@
WriteNoBom "src\main\java\com\acme\notes\note\NoteDto.java" $noteDtoCode

# --- Correction NoteController.java ---
$noteCtrlPath = Join-Path $projRoot "src\main\java\com\acme\notes\note\NoteController.java"
if (Test-Path $noteCtrlPath) {
  $code = Get-Content $noteCtrlPath -Raw
  # Remplacer note.getOwner() par note.getOwner().getEmail()
  $code = $code -replace "getOwner\(\)","getOwner().getEmail()"
  [IO.File]::WriteAllText($noteCtrlPath,$code,$utf8NoBom)
  Write-Host "✅ Corrected NoteController.java"
} else {
  Write-Host "❌ Fichier introuvable : $noteCtrlPath"
}

# --- Correction Share.java (ajout setter pour permission + type enum) ---
$sharePath = Join-Path $projRoot "src\main\java\com\acme\notes\share\Share.java"
if (Test-Path $sharePath) {
  $code = Get-Content $sharePath -Raw

  if ($code -notmatch "enum Permission") {
    $enumCode = @'
package com.acme.notes.share;

public enum Permission {
    READ,
    WRITE
}
'@
    WriteNoBom "src\main\java\com\acme\notes\share\Permission.java" $enumCode
    Write-Host "✅ Created Permission.java"
  }

  # Corriger le type du champ permission
  $code = $code -replace 'private String permission\s*=\s*".*";','@Enumerated(javax.persistence.EnumType.STRING)`r`n    @Column(nullable = false)`r`n    private Permission permission = Permission.READ;'

  # Ajouter un getter/setter corrects si pas présents
  if ($code -notmatch "Permission getPermission") {
    $code += @'

    public Permission getPermission() {
        return permission;
    }

    public void setPermission(Permission permission) {
        this.permission = permission;
    }
'@
  }

  [IO.File]::WriteAllText($sharePath,$code,$utf8NoBom)
  Write-Host "✅ Corrected Share.java"
} else {
  Write-Host "❌ Fichier introuvable : $sharePath"
}

# --- Correction ShareRepository.java (ajout findByIdAndNote) ---
$repoPath = Join-Path $projRoot "src\main\java\com\acme\notes\share\ShareRepository.java"
if (Test-Path $repoPath) {
  $code = Get-Content $repoPath -Raw
  if ($code -notmatch "findByIdAndNote") {
    $code = $code -replace "(public interface ShareRepository[^\{]+\{)","`$1`r`n    java.util.Optional<Share> findByIdAndNote(Long id, com.acme.notes.note.Note note);"
  }
  [IO.File]::WriteAllText($repoPath,$code,$utf8NoBom)
  Write-Host "✅ Corrected ShareRepository.java"
} else {
  Write-Host "❌ Fichier introuvable : $repoPath"
}

# --- ShareDto.java ---
$shareDtoPath = Join-Path $projRoot "src\main\java\com\acme\notes\share\ShareDto.java"
$shareDtoCode = @'
package com.acme.notes.share;

public record ShareDto(
    Long id,
    Long noteId,
    String sharedWithUserEmail,
    String permission
) {
    public static ShareDto from(Share share) {
        return new ShareDto(
            share.getId(),
            share.getNote() != null ? share.getNote().getId() : null,
            share.getSharedWith() != null ? share.getSharedWith().getEmail() : null,
            share.getPermission() != null ? share.getPermission().name() : null
        );
    }
}
'@
WriteNoBom "src\main\java\com\acme\notes\share\ShareDto.java" $shareDtoCode

# --- Visibility.java ---
$visPath = Join-Path $projRoot "src\main\java\com\acme\notes\note\Visibility.java"
$visCode = @'
package com.acme.notes.note;

public enum Visibility {
    PRIVATE,
    SHARED,
    PUBLIC
}
'@
WriteNoBom "src\main\java\com\acme\notes\note\Visibility.java" $visCode
