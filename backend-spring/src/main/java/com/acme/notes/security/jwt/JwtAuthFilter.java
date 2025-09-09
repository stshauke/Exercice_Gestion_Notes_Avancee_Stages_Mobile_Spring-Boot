package com.acme.notes.security.jwt;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.context.annotation.Lazy;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

/**
 * Filtre JWT : Authorization: Bearer <token>
 * - extrait le subject (email)
 * - valide le token
 * - pose l'Authentication
 */
@Component
public class JwtAuthFilter extends OncePerRequestFilter {

  private final JwtService jwtService;                  // doit exposer: extractSubject(String), isValid(String token, String subject)
  private final UserDetailsService userDetailsService;

  public JwtAuthFilter(JwtService jwtService, @Lazy UserDetailsService userDetailsService) {
    this.jwtService = jwtService;
    this.userDetailsService = userDetailsService;
  }

  @Override
  protected boolean shouldNotFilter(HttpServletRequest req) {
    String p = req.getServletPath();
    return p.startsWith("/api/v1/auth") || "/api/v1/health".equals(p);
  }

  @Override
  protected void doFilterInternal(HttpServletRequest request,
                                  HttpServletResponse response,
                                  FilterChain chain) throws ServletException, IOException {
    try {
      String header = request.getHeader("Authorization");
      if (header != null && header.startsWith("Bearer ")) {
        String token = header.substring(7);
        String email = jwtService.extractSubject(token);              // <-- adapte si ton service a un nom différent
        if (email != null
            && SecurityContextHolder.getContext().getAuthentication() == null
            && jwtService.isValid(token, email)) {                    // <-- ton service veut (token, subject)
          UserDetails ud = userDetailsService.loadUserByUsername(email);
          UsernamePasswordAuthenticationToken auth =
              new UsernamePasswordAuthenticationToken(ud, null, ud.getAuthorities());
          auth.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));
          SecurityContextHolder.getContext().setAuthentication(auth);
        }
      }
    } catch (Exception ignored) {}
    chain.doFilter(request, response);
  }
}