package com.acme.notes.share;

import com.acme.notes.user.User;

public record ShareDto(Long id, Long noteId, String sharedWith, Permission permission) {

    public static ShareDto from(Share share) {
        return new ShareDto(
                share.getId(),
                share.getNote().getId(),
                share.getUser().getEmail(),
                share.getPermission()
        );
    }
}