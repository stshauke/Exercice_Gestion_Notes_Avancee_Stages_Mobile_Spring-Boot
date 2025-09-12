package com.acme.notes.note;

public record NoteViewDto(
    Long id,
    String title,
    String contentMd,
    String visibility
) {
    public static NoteViewDto from(Note n) {
        return new NoteViewDto(
            n.getId(),
            n.getTitle(),
            n.getContentMd(),
            n.getVisibility().name() // enum -> String
        );
    }
}
