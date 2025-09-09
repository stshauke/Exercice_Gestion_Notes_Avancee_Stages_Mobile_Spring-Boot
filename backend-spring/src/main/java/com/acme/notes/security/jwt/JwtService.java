package com.acme.notes.security.jwt;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.nio.charset.StandardCharsets;
import java.security.Key;
import java.util.Date;
import java.util.Map;

@Service
public class JwtService {
  private final Key key;
  private final long validityMs;

  public JwtService(
      @Value("${JWT_SECRET:0123456789abcdef0123456789abcdef}") String secret,
      @Value("${JWT_EXP_MINUTES:120}") long expMinutes) {
    this.key = Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8));
    this.validityMs = expMinutes * 60_000;
  }

  public String generate(String subject, Map<String, Object> claims) {
    long now = System.currentTimeMillis();
    return Jwts.builder()
      .setClaims(claims)
      .setSubject(subject)
      .setIssuedAt(new Date(now))
      .setExpiration(new Date(now + validityMs))
      .signWith(key, SignatureAlgorithm.HS256)
      .compact();
  }

  public String extractSubject(String token) {
    return Jwts.parserBuilder().setSigningKey(key).build()
      .parseClaimsJws(token).getBody().getSubject();
  }

  public boolean isValid(String token, String subject) {
    try {
      Claims c = Jwts.parserBuilder().setSigningKey(key).build()
        .parseClaimsJws(token).getBody();
      return subject.equals(c.getSubject()) && c.getExpiration().after(new Date());
    } catch (Exception e) {
      return false;
    }
  }
}