package com.acme.notes.note;

import com.acme.notes.tag.Tag;
import jakarta.persistence.*;

@Entity
@Table(name = "note_tags")
public class NoteTag {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(optional = false)
    @JoinColumn(name = "note_id")
    private Note note;

    @ManyToOne(optional = false)
    @JoinColumn(name = "tag_id")
    private Tag tag;

    public NoteTag() {}
    public NoteTag(Note note, Tag tag) {
        this.note = note;
        this.tag = tag;
    }

    public Long getId() { return id; }
    public Note getNote() { return note; }
    public Tag getTag() { return tag; }
}