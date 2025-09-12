# fix-sharedto.ps1
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

# --- ShareDto.java ---
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
            share.getNote().getId(),
            share.getSharedWith().getEmail(),
            share.getPermission().name()
        );
    }
}
'@

WriteNoBom "src\main\java\com\acme\notes\share\ShareDto.java" $shareDtoCode
