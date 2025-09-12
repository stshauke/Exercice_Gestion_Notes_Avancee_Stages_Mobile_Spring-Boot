// src/main/java/com/acme/notes/note/NoteCreateDto.java
package com.acme.notes.note;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public record NoteCreateDto(
    String title,
    String contentMd,
    Visibility visibility
) {}
