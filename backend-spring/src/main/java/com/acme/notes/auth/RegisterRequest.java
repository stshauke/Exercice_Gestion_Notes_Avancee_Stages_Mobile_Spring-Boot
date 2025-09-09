package com.acme.notes.auth;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;

public record RegisterRequest(@Email @NotBlank String email, @NotBlank String password) {}