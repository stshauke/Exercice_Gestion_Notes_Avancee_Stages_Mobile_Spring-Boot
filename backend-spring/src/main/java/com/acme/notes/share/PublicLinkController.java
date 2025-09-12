package com.acme.notes.share;

import com.acme.notes.note.Note;
import com.acme.notes.note.NoteViewDto;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1")
public class PublicLinkController {

    private final PublicLinkService service;

    public PublicLinkController(PublicLinkService service) {
        this.service = service;
    }

    @PostMapping("/notes/{id}/public-links")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<PublicLinkDto> create(@AuthenticationPrincipal UserDetails me,
                                                @PathVariable Long id) {
        var pl = service.createLink(id, me.getUsername());
        return ResponseEntity.ok(new PublicLinkDto(pl.getUrlToken(), pl.getExpiresAt()));
    }

    @GetMapping("/public/{token}")
    public ResponseEntity<NoteViewDto> get(@PathVariable String token) {
        Note note = service.getNoteByToken(token);
        return ResponseEntity.ok(NoteViewDto.from(note));
    }
}