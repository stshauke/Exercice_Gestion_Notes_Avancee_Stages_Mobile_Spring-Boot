package com.acme.notes;

import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;
import java.util.Map;

@RestController
@RequestMapping("/api/v1")
public class AuthMeController {
  @GetMapping("/me")
  public Map<String,Object> me(@AuthenticationPrincipal UserDetails user) {
    return Map.of("email", user.getUsername(), "authorities", user.getAuthorities());
  }
}