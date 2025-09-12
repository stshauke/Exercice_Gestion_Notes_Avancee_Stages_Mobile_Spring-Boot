# fix-note-dtos.ps1
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
$projRoot = "C:\Users\tshau\dev\notes-suite\backend-spring"

function WriteNoBom($relPath, $content) {
  $full = Join-Path $projRoot $relPath
  $dir = Split-Path $full
  if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
  if (Test-Path $full) { Copy-Item $full "$full.bak" -Force }
  [IO.File]::WriteAllText($full, $content, $utf8NoBom)
  Write-Host "✅ Wrote: $full"
}

# --- NoteDto.java ---
$noteDtoCode = @'
package com.acme.notes.note;

import com.acme.notes.share.Visibility;

public record NoteDto(
    Long id,
    String title,
    String contentMd,
    Visibility visibility
) {}
'@
WriteNoBom "src\main\java\com\acme\notes\note\NoteDto.java" $noteDtoCode

# --- NoteCreateDto.java ---
$noteCreateDtoCode = @'
package com.acme.notes.note;

import com.acme.notes.share.Visibility;

public record NoteCreateDto(
    String title,
    String contentMd,
    Visibility visibility
) {}
'@
WriteNoBom "src\main\java\com\acme\notes\note\NoteCreateDto.java" $noteCreateDtoCode

# --- NoteUpdateDto.java ---
$noteUpdateDtoCode = @'
package com.acme.notes.note;

import com.acme.notes.share.Visibility;

public record NoteUpdateDto(
    String title,
    String contentMd,
    Visibility visibility
) {}
'@
WriteNoBom "src\main\java\com\acme\notes\note\NoteUpdateDto.java" $noteUpdateDtoCode
