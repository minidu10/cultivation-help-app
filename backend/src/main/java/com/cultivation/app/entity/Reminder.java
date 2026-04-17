package com.cultivation.app.entity;

import java.time.LocalDateTime;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.PrePersist;
import jakarta.persistence.Table;

@Entity
@Table(name = "reminders")
public class Reminder {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "crop_id", nullable = false)
    private Crop crop;

    @Column(nullable = false, length = 150)
    private String title;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 40)
    private ReminderType type = ReminderType.OTHER;

    @Column(name = "reminder_at", nullable = false)
    private LocalDateTime reminderAt;

    @Column(nullable = false)
    private Boolean enabled = true;

    @Column(name = "ai_recommended", nullable = false)
    private Boolean aiRecommended = false;

    @Column(nullable = false)
    private Boolean completed = false;

    @Column(length = 400)
    private String note;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    @PrePersist
    public void prePersist() {
        this.createdAt = LocalDateTime.now();
    }

    public enum ReminderType {
        FERTILIZER,
        IRRIGATION,
        PEST_CONTROL,
        HARVEST,
        OTHER
    }

    public Long getId() { return id; }

    public Crop getCrop() { return crop; }
    public void setCrop(Crop crop) { this.crop = crop; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public ReminderType getType() { return type; }
    public void setType(ReminderType type) { this.type = type; }

    public LocalDateTime getReminderAt() { return reminderAt; }
    public void setReminderAt(LocalDateTime reminderAt) { this.reminderAt = reminderAt; }

    public Boolean getEnabled() { return enabled; }
    public void setEnabled(Boolean enabled) { this.enabled = enabled; }

    public Boolean getAiRecommended() { return aiRecommended; }
    public void setAiRecommended(Boolean aiRecommended) { this.aiRecommended = aiRecommended; }

    public Boolean getCompleted() { return completed; }
    public void setCompleted(Boolean completed) { this.completed = completed; }

    public String getNote() { return note; }
    public void setNote(String note) { this.note = note; }

    public LocalDateTime getCreatedAt() { return createdAt; }
}
