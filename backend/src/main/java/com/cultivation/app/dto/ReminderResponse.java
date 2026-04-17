package com.cultivation.app.dto;

import java.time.LocalDateTime;

import com.cultivation.app.entity.Reminder;

public class ReminderResponse {

    private Long id;
    private Long cropId;
    private String title;
    private Reminder.ReminderType type;
    private LocalDateTime reminderAt;
    private Boolean enabled;
    private Boolean aiRecommended;
    private Boolean completed;
    private String note;
    private LocalDateTime createdAt;

    public ReminderResponse(Reminder reminder) {
        this.id = reminder.getId();
        this.cropId = reminder.getCrop().getId();
        this.title = reminder.getTitle();
        this.type = reminder.getType();
        this.reminderAt = reminder.getReminderAt();
        this.enabled = reminder.getEnabled();
        this.aiRecommended = reminder.getAiRecommended();
        this.completed = reminder.getCompleted();
        this.note = reminder.getNote();
        this.createdAt = reminder.getCreatedAt();
    }

    public Long getId() { return id; }
    public Long getCropId() { return cropId; }
    public String getTitle() { return title; }
    public Reminder.ReminderType getType() { return type; }
    public LocalDateTime getReminderAt() { return reminderAt; }
    public Boolean getEnabled() { return enabled; }
    public Boolean getAiRecommended() { return aiRecommended; }
    public Boolean getCompleted() { return completed; }
    public String getNote() { return note; }
    public LocalDateTime getCreatedAt() { return createdAt; }
}
