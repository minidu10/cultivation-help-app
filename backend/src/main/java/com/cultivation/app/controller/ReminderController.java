package com.cultivation.app.controller;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.cultivation.app.dto.ReminderRequest;
import com.cultivation.app.dto.ReminderResponse;
import com.cultivation.app.entity.User;
import com.cultivation.app.service.ReminderService;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;

@RestController
@RequestMapping("/api")
@Tag(name = "Reminders", description = "Manage crop reminders")
public class ReminderController {

    private final ReminderService reminderService;

    public ReminderController(ReminderService reminderService) {
        this.reminderService = reminderService;
    }

    @GetMapping("/crops/{cropId}/reminders")
    @Operation(summary = "Get reminders for a crop")
    public ResponseEntity<List<ReminderResponse>> getReminders(
            @PathVariable Long cropId,
            @AuthenticationPrincipal User currentUser) {
        return ResponseEntity.ok(reminderService.getReminders(cropId, currentUser));
    }

    @PostMapping("/crops/{cropId}/reminders")
    @Operation(summary = "Create a reminder for a crop")
    public ResponseEntity<ReminderResponse> createReminder(
            @PathVariable Long cropId,
            @RequestBody ReminderRequest request,
            @AuthenticationPrincipal User currentUser) {
        return ResponseEntity.ok(reminderService.createReminder(cropId, request, currentUser));
    }

    @PutMapping("/crops/{cropId}/reminders/{reminderId}")
    @Operation(summary = "Update a reminder")
    public ResponseEntity<ReminderResponse> updateReminder(
            @PathVariable Long cropId,
            @PathVariable Long reminderId,
            @RequestBody ReminderRequest request,
            @AuthenticationPrincipal User currentUser) {
        return ResponseEntity.ok(reminderService.updateReminder(reminderId, request, currentUser));
    }

    @DeleteMapping("/crops/{cropId}/reminders/{reminderId}")
    @Operation(summary = "Delete a reminder")
    public ResponseEntity<Void> deleteReminder(
            @PathVariable Long cropId,
            @PathVariable Long reminderId,
            @AuthenticationPrincipal User currentUser) {
        reminderService.deleteReminder(reminderId, currentUser);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/reminders/due")
    @Operation(summary = "Get due reminders for current user")
    public ResponseEntity<List<ReminderResponse>> getDueReminders(
            @AuthenticationPrincipal User currentUser) {
        return ResponseEntity.ok(reminderService.getDueReminders(currentUser));
    }
}
