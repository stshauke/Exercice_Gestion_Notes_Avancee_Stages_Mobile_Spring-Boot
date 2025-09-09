package com.acme.notes;

import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1")
public class AuthPingController {
  @GetMapping("/ping-auth")
  public String ping() { return "ok"; }
}