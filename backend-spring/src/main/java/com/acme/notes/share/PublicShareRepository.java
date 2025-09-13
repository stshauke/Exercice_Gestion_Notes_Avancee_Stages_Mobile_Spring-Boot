package com.acme.notes.share;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface PublicShareRepository extends JpaRepository<PublicShare, Long> {
    Optional<PublicShare> findByUrlToken(String urlToken);
}
