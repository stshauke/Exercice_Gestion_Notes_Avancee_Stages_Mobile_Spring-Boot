package com.acme.notes.note;

public record NoteViewDto(Long id, String title, String content) {
  public static NoteViewDto from(Note n) {
    return new NoteViewDto(n.getId(), n.getTitle(), n.getContent());
  }
}