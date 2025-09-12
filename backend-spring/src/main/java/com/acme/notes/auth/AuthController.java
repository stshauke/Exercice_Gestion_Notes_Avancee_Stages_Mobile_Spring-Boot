package com.acme.notes.auth;

import com.acme.notes.security.jwt.JwtService;
import com.acme.notes.user.User;
import com.acme.notes.user.UserRepository;
import com.acme.notes.user.Role;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.time.Instant;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
public class AuthController {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final AuthenticationManager authenticationManager;
    private final JwtService jwtService;

    /**
     * Inscription d'un nouvel utilisateur
     */
    @PostMapping("/register")
    public ResponseEntity<AuthResponse> register(@Valid @RequestBody RegisterRequest request) {
        if (userRepository.existsByEmail(request.email())) {
            return ResponseEntity.badRequest().build();
        }

        Role role;
        try {
            role = Role.valueOf(request.role().toUpperCase());
        } catch (IllegalArgumentException e) {
            role = Role.USER;
        }

        var user = User.builder()
            .email(request.email())
            .passwordHash(passwordEncoder.encode(request.password())) // ✅ cohérent avec l’entité
            .createdAt(Instant.now())
            .role(role)
            .build();

        userRepository.save(user);

        String token = jwtService.generate(
            user.getEmail(),
            Map.of("role", user.getRole().name())
        );

        return ResponseEntity.ok(new AuthResponse(token, user.getId(), user.getEmail()));
    }

    /**
     * Connexion utilisateur
     */
    @PostMapping("/login")
    public ResponseEntity<AuthResponse> login(@Valid @RequestBody AuthRequest request) {
        authenticationManager.authenticate(
            new UsernamePasswordAuthenticationToken(request.email(), request.password())
        );

        var user = userRepository.findByEmail(request.email())
            .orElseThrow();

        String token = jwtService.generate(
            user.getEmail(),
            Map.of("role", user.getRole().name())
        );

        return ResponseEntity.ok(new AuthResponse(token, user.getId(), user.getEmail()));
    }
}
