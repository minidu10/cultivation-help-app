package com.cultivation.app.storage;

import java.util.Optional;

/**
 * Where uploaded photos live. Keys look like {@code avatars/12/photo.jpg}, so
 * everything belonging to one farmer can be erased by prefix.
 */
public interface MediaStorage {

    void put(String key, byte[] data, String contentType);

    Optional<byte[]> get(String key);

    void delete(String key);

    /** Removes every object whose key starts with {@code prefix}. */
    void deletePrefix(String prefix);
}
