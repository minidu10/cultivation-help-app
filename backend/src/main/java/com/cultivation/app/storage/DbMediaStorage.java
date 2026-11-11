package com.cultivation.app.storage;

import java.util.Optional;

import org.springframework.boot.autoconfigure.condition.ConditionalOnExpression;
import org.springframework.jdbc.core.simple.JdbcClient;
import org.springframework.stereotype.Component;

/**
 * Photos in the database, for local development and tests, where no bucket is
 * configured. Set {@code S3_BUCKET} and photos go to S3 instead.
 */
@Component
@ConditionalOnExpression("'${app.storage.s3-bucket:}'.isBlank()")
public class DbMediaStorage implements MediaStorage {

    private final JdbcClient jdbc;

    public DbMediaStorage(JdbcClient jdbc) {
        this.jdbc = jdbc;
    }

    @Override
    public void put(String key, byte[] data, String contentType) {
        jdbc.sql("""
                INSERT INTO media_objects (object_key, content_type, data) VALUES (:k, :t, :d)
                ON CONFLICT (object_key) DO UPDATE SET content_type = :t, data = :d
                """)
            .param("k", key).param("t", contentType).param("d", data)
            .update();
    }

    @Override
    public Optional<byte[]> get(String key) {
        return jdbc.sql("SELECT data FROM media_objects WHERE object_key = :k")
            .param("k", key)
            .query((rs, i) -> rs.getBytes(1))
            .optional();
    }

    @Override
    public void delete(String key) {
        jdbc.sql("DELETE FROM media_objects WHERE object_key = :k").param("k", key).update();
    }

    @Override
    public void deletePrefix(String prefix) {
        jdbc.sql("DELETE FROM media_objects WHERE starts_with(object_key, :p)").param("p", prefix).update();
    }
}
