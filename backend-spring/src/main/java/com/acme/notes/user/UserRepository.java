package com.acme.notes.user;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

/**
 * Repository Spring Data JPA pour l'entité User.
 */
@Repository
public interface UserRepository extends JpaRepository<User, Long> {

    /**
     * Recherche un utilisateur par email (unique).
     * @param email l'email de l'utilisateur
     * @return un Optional<User>
     */
    Optional<User> findByEmail(String email);

    /**
     * Vérifie si un utilisateur existe déjà avec cet email.
     * @param email l'email à vérifier
     * @return true si un utilisateur existe déjà
     */
    boolean existsByEmail(String email);
}
