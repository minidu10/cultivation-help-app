package com.cultivation.app.storage;

import java.net.URI;
import java.util.List;
import java.util.Optional;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnExpression;
import org.springframework.stereotype.Component;

import jakarta.annotation.PreDestroy;
import software.amazon.awssdk.core.sync.RequestBody;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.S3Configuration;
import software.amazon.awssdk.services.s3.model.DeleteObjectRequest;
import software.amazon.awssdk.services.s3.model.DeleteObjectsRequest;
import software.amazon.awssdk.services.s3.model.GetObjectRequest;
import software.amazon.awssdk.services.s3.model.NoSuchKeyException;
import software.amazon.awssdk.services.s3.model.ObjectIdentifier;
import software.amazon.awssdk.services.s3.model.PutObjectRequest;
import software.amazon.awssdk.services.s3.model.S3Object;

/**
 * Photos in an S3 bucket, or anything that speaks the S3 API (R2, MinIO) when
 * an endpoint is set. Credentials come from the default chain, which on EC2
 * is the instance's IAM role, so there is no key to leak.
 */
@Component
@ConditionalOnExpression("!'${app.storage.s3-bucket:}'.isBlank()")
public class S3MediaStorage implements MediaStorage {

    private static final Logger log = LoggerFactory.getLogger(S3MediaStorage.class);

    private final S3Client s3;
    private final String bucket;

    public S3MediaStorage(@Value("${app.storage.s3-bucket}") String bucket,
                          @Value("${app.storage.s3-region:ap-southeast-1}") String region,
                          @Value("${app.storage.s3-endpoint:}") String endpoint) {
        this.bucket = bucket;
        var builder = S3Client.builder().region(Region.of(region));
        if (!endpoint.isBlank()) {
            builder.endpointOverride(URI.create(endpoint))
                   .serviceConfiguration(S3Configuration.builder().pathStyleAccessEnabled(true).build());
        }
        this.s3 = builder.build();
        log.info("Photos are stored in S3 bucket {}", bucket);
    }

    @Override
    public void put(String key, byte[] data, String contentType) {
        s3.putObject(PutObjectRequest.builder().bucket(bucket).key(key).contentType(contentType).build(),
            RequestBody.fromBytes(data));
    }

    @Override
    public Optional<byte[]> get(String key) {
        try {
            return Optional.of(s3.getObjectAsBytes(GetObjectRequest.builder().bucket(bucket).key(key).build())
                .asByteArray());
        } catch (NoSuchKeyException ex) {
            return Optional.empty();
        }
    }

    @Override
    public void delete(String key) {
        s3.deleteObject(DeleteObjectRequest.builder().bucket(bucket).key(key).build());
    }

    @Override
    public void deletePrefix(String prefix) {
        s3.listObjectsV2Paginator(b -> b.bucket(bucket).prefix(prefix)).forEach(page -> {
            List<ObjectIdentifier> keys = page.contents().stream()
                .map(S3Object::key)
                .map(k -> ObjectIdentifier.builder().key(k).build())
                .toList();
            if (!keys.isEmpty()) {
                s3.deleteObjects(DeleteObjectsRequest.builder().bucket(bucket)
                    .delete(d -> d.objects(keys)).build());
            }
        });
    }

    @PreDestroy
    void close() {
        s3.close();
    }
}
