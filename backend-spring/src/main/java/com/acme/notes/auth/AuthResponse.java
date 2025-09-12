// src/main/java/com/acme/notes/auth/AuthResponse.java
package com.acme.notes.auth;

public record AuthResponse(
    String token,
    Long id,
    String email
) {}