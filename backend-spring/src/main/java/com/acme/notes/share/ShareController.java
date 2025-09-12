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