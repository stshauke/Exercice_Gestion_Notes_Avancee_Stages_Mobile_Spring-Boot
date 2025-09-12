// src/main/java/com/acme/notes/security/jwt/JwtAuthFilter.java
package com.acme.notes.security.jwt;

import com.acme.notes.user.User;
import com.acme.notes.user.UserRepository;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.context.annotation.Lazy;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.List;
import org.springframework.security.core.authority.SimpleGrantedAuthority;

@Component
public class JwtAuthFilter extends OncePerRequestFilter {

    private final JwtService jwtService;
    private final UserRepository userRepository;

    public JwtAuthFilter(JwtService jwtService, @Lazy UserRepository userRepository) {
        this.jwtService = jwtService;
        this.userRepository = userRepository;
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain chain) throws ServletException, IOException {

        String header = request.getHeader("Authorization");

        if (header != null && header.startsWith("Bearer ")) {
            String token = header.substring(7);

            try {
                String email = jwtService.extractSubject(token);

                if (email != null && SecurityContextHolder.getContext().getAuthentication() == null) {
                    boolean isValid = jwtService.isValid(token, email);

                    if (isValid) {
                        User user = userRepository.findByEmail(email).orElse(null);
                                System.out.println("✅ JWT OK pour user: " + user.getEmail() + " role=" + user.getRole());

                        if (user != null) {
                            // ✅ On construit un vrai UserDetails avec ses rôles
                            UserDetails userDetails = org.springframework.security.core.userdetails.User
                                    .withUsername(user.getEmail())
                                    .password(user.getPasswordHash())
                                    .authorities("ROLE_" + user.getRole().name())
                                    .build();

                            UsernamePasswordAuthenticationToken auth =
    new UsernamePasswordAuthenticationToken(
        user, // 👈 garde l'entité User comme principal
        null,
        List.of(new SimpleGrantedAuthority("ROLE_" + user.getRole().name()))
    );

                            auth.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));
                            SecurityContextHolder.getContext().setAuthentication(auth);
                        }
                        } else {
        System.out.println("❌ User introuvable en DB pour: " + email);
    }
                    
                }
            } catch (Exception e) {
                System.out.println("JWT ERROR: " + e.getMessage());
            }
        }

        chain.doFilter(request, response);
    }
}
