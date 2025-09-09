package com.acme.notes.auth;

import com.acme.notes.security.jwt.JwtService;
import com.acme.notes.user.Role;
import com.acme.notes.user.User;
import com.acme.notes.user.UserRepository;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/v1/auth")
public class AuthController {
  private final UserRepository users;
  private final PasswordEncoder encoder;
  private final AuthenticationManager authManager;
  private final JwtService jwt;

  public AuthController(UserRepository users, PasswordEncoder encoder, AuthenticationManager authManager, JwtService jwt) {
    this.users = users; this.encoder = encoder; this.authManager = authManager; this.jwt = jwt;
  }

  @PostMapping("/register")
  public ResponseEntity<AuthResponse> register(@Valid @RequestBody RegisterRequest req) {
    if (users.existsByEmail(req.email())) {
      return ResponseEntity.badRequest().build();
    }
    var u = User.builder()
      .email(req.email())
      .password(encoder.encode(req.password()))
      .role(Role.USER)
      .build();
    users.save(u);
    String token = jwt.generate(u.getEmail(), Map.of("role", u.getRole().name()));
    return ResponseEntity.ok(new AuthResponse(token));
  }

  @PostMapping("/login")
  public ResponseEntity<AuthResponse> login(@Valid @RequestBody AuthRequest req) {
    authManager.authenticate(new UsernamePasswordAuthenticationToken(req.email(), req.password()));
    var u = users.findByEmail(req.email()).orElseThrow();
    String token = jwt.generate(u.getEmail(), Map.of("role", u.getRole().name()));
    return ResponseEntity.ok(new AuthResponse(token));
  }
}