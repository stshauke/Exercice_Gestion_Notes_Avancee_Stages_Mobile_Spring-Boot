package com.acme.notes.share;

import com.acme.notes.user.User;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/shares/public")
public class PublicShareController {

    private final ShareService service;

    public PublicShareController(ShareService service) {
        this.service = service;
    }

    // 🔹 Créer un lien public
    @PostMapping("/{noteId}")
    public PublicShareDto create(@AuthenticationPrincipal User user,
                                 @PathVariable Long noteId) {
        return service.createPublicShare(user, noteId);
    }

    // 🔹 Consulter une note via token
    @GetMapping("/view/{token}")
    public PublicShareDto view(@PathVariable String token) {
        return service.getPublicShare(token); // ✅ au lieu de getNoteByToken
    }
}
