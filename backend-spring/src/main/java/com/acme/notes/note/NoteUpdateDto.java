// src/main/java/com/acme/notes/note/NoteUpdateDto.java
package com.acme.notes.note;

import jakarta.validation.constraints.Size;

public record NoteUpdateDto(

        @Size(max = 255, message = "Le titre ne doit pas dépasser 255 caractères")
        String title,

        String contentMd,

        Visibility visibility
) {
    public boolean hasTitle() {
        return title != null && !title.isBlank();
    }

    public boolean hasContent() {
        return contentMd != null && !contentMd.isBlank();
    }

    public boolean hasVisibility() {
        return visibility != null;
    }
}
