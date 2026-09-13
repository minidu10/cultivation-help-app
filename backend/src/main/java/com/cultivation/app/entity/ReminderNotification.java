package com.cultivation.app.entity;

import java.time.LocalDateTime;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.PrePersist;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;

/**
 * Record that one advance notice for one reminder has been emailed.
 *
 * The unique constraint on (reminder_id, lead_days) is the actual guarantee
 * against duplicate emails — if the job runs twice in a day, or two instances
 * run at once, the second insert fails rather than sending a second mail.
 */
@Entity
@Table(
    name = "reminder_notifications",
    uniqueConstraints = @UniqueConstraint(
        name = "uq_reminder_notification",
        columnNames = { "reminder_id", "lead_days" })
)
public class ReminderNotification {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "reminder_id", nullable = false)
    private Long reminderId;

    /** How many days before the reminder this notice was for: 2, then 1. */
    @Column(name = "lead_days", nullable = false)
    private Integer leadDays;

    @Column(name = "sent_at", nullable = false)
    private LocalDateTime sentAt;

    protected ReminderNotification() {
    }

    public ReminderNotification(Long reminderId, Integer leadDays) {
        this.reminderId = reminderId;
        this.leadDays = leadDays;
    }

    @PrePersist
    void prePersist() {
        if (sentAt == null) {
            sentAt = LocalDateTime.now();
        }
    }

    public Long getId() { return id; }

    public Long getReminderId() { return reminderId; }
    public void setReminderId(Long reminderId) { this.reminderId = reminderId; }

    public Integer getLeadDays() { return leadDays; }
    public void setLeadDays(Integer leadDays) { this.leadDays = leadDays; }

    public LocalDateTime getSentAt() { return sentAt; }
    public void setSentAt(LocalDateTime sentAt) { this.sentAt = sentAt; }
}
