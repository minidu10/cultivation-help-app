package com.cultivation.app.entity;

import java.time.LocalDateTime;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.PrePersist;
import jakarta.persistence.Table;

/** An app install that can receive push notifications. */
@Entity
@Table(name = "device_tokens")
public class DeviceToken {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(nullable = false, length = 512)
    private String token;

    /** android or ios. */
    @Column(nullable = false, length = 20)
    private String platform;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    @Column(name = "last_seen_at", nullable = false)
    private LocalDateTime lastSeenAt;

    protected DeviceToken() {
    }

    public DeviceToken(User user, String token, String platform) {
        this.user = user;
        this.token = token;
        this.platform = platform;
    }

    @PrePersist
    void prePersist() {
        LocalDateTime now = LocalDateTime.now();
        if (createdAt == null) {
            createdAt = now;
        }
        if (lastSeenAt == null) {
            lastSeenAt = now;
        }
    }

    /** The same install, now signed in as [owner]; or simply seen again. */
    public void claim(User owner, String platform) {
        this.user = owner;
        this.platform = platform;
        this.lastSeenAt = LocalDateTime.now();
    }

    public Long getId() { return id; }

    public User getUser() { return user; }

    public String getToken() { return token; }

    public String getPlatform() { return platform; }

    public LocalDateTime getLastSeenAt() { return lastSeenAt; }
}
