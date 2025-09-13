package com.acme.notes.share;

import com.acme.notes.user.User;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1")
public class ShareController {

    private final ShareService service;

    public ShareController(ShareService service) {
        this.service = service;
    }

    // ---- Partage privé (avec un utilisateur) ----
    @PostMapping("/notes/{noteId}/shares")
    public ShareDto createPrivateShare(@AuthenticationPrincipal User user,
                                       @PathVariable Long noteId,
                                       @RequestParam String email,
                                       @RequestParam Permission permission) {
        return service.createShare(noteId, email, permission);
    }

    @GetMapping("/notes/{noteId}/shares")
    public List<ShareDto> listNoteShares(@AuthenticationPrincipal User user,
                                         @PathVariable Long noteId) {
        return service.getShares(noteId);
    }

    @DeleteMapping("/notes/{noteId}/shares/{shareId}")
    public ResponseEntity<Void> deleteShare(@AuthenticationPrincipal User user,
                                            @PathVariable Long noteId,
                                            @PathVariable Long shareId) {
        service.deleteShare(noteId, shareId);
        return ResponseEntity.noContent().build();
    }

    // ---- Partages (privés + publics) reçus ----
    @GetMapping("/shares/all")
    public List<PublicShareDto> listAllShares(@AuthenticationPrincipal User user) {
        return service.getAllSharesForUser(user);
    }

    // ---- Partages publics ----
    // @PostMapping("/shares/public/{noteId}")
    // public PublicShareDto createPublicShare(@AuthenticationPrincipal User user,
    //                                         @PathVariable Long noteId) {
    //     return service.createPublicShare(user, noteId);
    // }

    // @GetMapping("/shares/public/view/{token}")
    // public PublicShareDto viewPublic(@PathVariable String token) {
    //     return service.getPublicShare(token);
    // }
}
