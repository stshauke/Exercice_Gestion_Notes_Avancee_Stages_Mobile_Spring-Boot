package com.acme.notes.note;

import com.acme.notes.user.User;
import com.acme.notes.user.UserRepository;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/notes")
public class NoteController {

    private final NoteService service;
    private final UserRepository userRepository;

    public NoteController(NoteService service, UserRepository userRepository) {
        this.service = service;
        this.userRepository = userRepository;
    }

    private User getCurrentUser(UserDetails userDetails) {
        return userRepository.findByEmail(userDetails.getUsername())
                .orElseThrow(() -> new RuntimeException("User not found: " + userDetails.getUsername()));
    }

    @GetMapping
    public List<NoteDto> all(@AuthenticationPrincipal UserDetails userDetails) {
        User user = getCurrentUser(userDetails);
        return service.getNotes(user);
    }

    @PostMapping
    public ResponseEntity<NoteDto> create(
            @AuthenticationPrincipal UserDetails userDetails,
            @Valid @RequestBody NoteCreateDto dto) {

        User user = getCurrentUser(userDetails);

        if (dto.title() == null || dto.title().isBlank()) {
            return ResponseEntity.badRequest().build();
        }
        if (dto.contentMd() == null || dto.contentMd().isBlank()) {
            return ResponseEntity.badRequest().build();
        }

        NoteDto created = service.create(user, dto);
        return ResponseEntity.ok(created);
    }

    @GetMapping("/{id}")
    public ResponseEntity<NoteDto> one(
            @AuthenticationPrincipal UserDetails userDetails,
            @PathVariable Long id) {

        User user = getCurrentUser(userDetails);
        return service.getNote(user, id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PutMapping("/{id}")
    public ResponseEntity<NoteDto> update(
            @AuthenticationPrincipal UserDetails userDetails,
            @PathVariable Long id,
            @Valid @RequestBody NoteUpdateDto dto) {

        User user = getCurrentUser(userDetails);
        return service.update(user, id, dto)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{id}")
public ResponseEntity<Void> delete(@AuthenticationPrincipal User user,
                                   @PathVariable Long id) {
    service.delete(user, id);
    return ResponseEntity.noContent().build();
}

}
