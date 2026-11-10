package com.cultivation.app.dto;

import java.time.LocalDateTime;

import com.cultivation.app.entity.Reminder;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public class ReminderRequest {

    @NotBlank(groups = OnCreate.class, message = "Reminder title is required")
    @Size(max = 150, message = "Title must be at most 150 characters")
    private String title;

    private Reminder.ReminderType type;

    @NotNull(groups = OnCreate.class, message = "Reminder time is required")
    private LocalDateTime reminderAt;

    private Boolean enabled;
    private Boolean aiRecommended;
    private Boolean completed;

    @Size(max = 400, message = "Note must be at most 400 characters")
    private String note;

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public Reminder.ReminderType getType() { return type; }
    public void setType(Reminder.ReminderType type) { this.type = type; }

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
}
