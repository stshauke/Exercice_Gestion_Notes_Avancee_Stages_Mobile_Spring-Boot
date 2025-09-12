# fix-dto-visibility.ps1
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
$projRoot = "C:\Users\tshau\dev\notes-suite\backend-spring"

function Fix-Import($relPath) {
  $full = Join-Path $projRoot $relPath
  if (Test-Path $full) {
    $code = Get-Content $full -Raw
    $code = $code -replace "import com\.acme\.notes\.share\.Visibility;","import com.acme.notes.note.Visibility;"
    [IO.File]::WriteAllText($full,$code,$utf8NoBom)
    Write-Host "✅ Corrected import in $relPath"
  } else {
    Write-Host "❌ Fichier introuvable : $full"
  }
}

Fix-Import "src\main\java\com\acme\notes\note\NoteCreateDto.java"
Fix-Import "src\main\java\com\acme\notes\note\NoteUpdateDto.java"
