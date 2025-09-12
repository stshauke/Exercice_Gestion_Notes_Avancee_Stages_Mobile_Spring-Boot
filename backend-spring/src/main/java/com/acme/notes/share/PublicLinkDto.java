package com.acme.notes.share;

import java.time.Instant;

public record PublicLinkDto(String urlToken, Instant expiresAt) {}