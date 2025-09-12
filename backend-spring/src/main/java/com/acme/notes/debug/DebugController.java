// src/main/java/com/acme/notes/debug/DebugController.java
package com.acme.notes.debug;

import com.acme.notes.security.jwt.JwtService;
import com.acme.notes.user.User;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/v1/debug")
public class DebugController {

    private final JwtService jwtService;

    public DebugController(JwtService jwtService) {
        this.jwtService = jwtService;
    }

    /**
     * Vérifie manuellement un token
     */
    @PostMapping("/token")
    public String debugToken(@RequestBody Map<String, String> request) {
        String token = request.get("token");
        try {
            System.out.println("=== DEBUG JWT TOKEN ===");
            System.out.println("Token: " + token);

            String email = jwtService.extractSubject(token);
            System.out.println("Extracted email: " + email);

            boolean isValid = jwtService.isValid(token, email);
            System.out.println("Token valid: " + isValid);

            return "Email: " + email + ", Valid: " + isValid;
        } catch (Exception e) {
            System.out.println("Error: " + e.getMessage());
            e.printStackTrace();
            return "Error: " + e.getMessage();
        }
    }

    /**
     * Retourne l'utilisateur courant extrait du JWT
     */
    @GetMapping("/whoami")
    public Map<String, Object> whoami(@AuthenticationPrincipal User user) {
        if (user == null) {
            return Map.of("authenticated", false);
        }
        return Map.of(
            "authenticated", true,
            "id", user.getId(),
            "email", user.getEmail(),
            "role", user.getRole().name()
        );
    }
}
