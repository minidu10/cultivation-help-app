package com.cultivation.app.service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

import com.cultivation.app.dto.ReminderRequest;
import com.cultivation.app.dto.ReminderResponse;
import com.cultivation.app.entity.Crop;
import com.cultivation.app.entity.Reminder;
import com.cultivation.app.entity.User;
import com.cultivation.app.exception.ApiException;
import com.cultivation.app.repository.CropRepository;
import com.cultivation.app.repository.ReminderRepository;

@Service
public class ReminderService {

    private final ReminderRepository reminderRepository;
    private final CropRepository cropRepository;

    public ReminderService(ReminderRepository reminderRepository, CropRepository cropRepository) {
        this.reminderRepository = reminderRepository;
        this.cropRepository = cropRepository;
    }

    public List<ReminderResponse> getReminders(Long cropId, User currentUser) {
        // An unknown crop is a 404, not an empty list that looks like "no reminders yet".
        findCrop(cropId, currentUser);
        return reminderRepository
            .findByCropIdAndCropUserIdOrderByReminderAtAsc(cropId, currentUser.getId())
            .stream()
            .map(ReminderResponse::new)
            .collect(Collectors.toList());
    }

    public List<ReminderResponse> getDueReminders(User currentUser) {
        return reminderRepository
            .findByCropUserIdAndEnabledTrueAndCompletedFalseAndReminderAtLessThanEqualOrderByReminderAtAsc(
                currentUser.getId(),
                LocalDateTime.now()
            )
            .stream()
            .map(ReminderResponse::new)
            .collect(Collectors.toList());
    }

    public ReminderResponse createReminder(Long cropId, ReminderRequest request, User currentUser) {
        // Title and time are enforced by the OnCreate validation group.
        Crop crop = findCrop(cropId, currentUser);

        Reminder reminder = new Reminder();
        reminder.setCrop(crop);
        reminder.setTitle(request.getTitle().trim());
        if (request.getType() != null) reminder.setType(request.getType());
        reminder.setReminderAt(request.getReminderAt());
        if (request.getEnabled() != null) reminder.setEnabled(request.getEnabled());
        if (request.getAiRecommended() != null) reminder.setAiRecommended(request.getAiRecommended());
        if (request.getCompleted() != null) reminder.setCompleted(request.getCompleted());
        reminder.setNote(request.getNote());

        return new ReminderResponse(reminderRepository.save(reminder));
    }

    public ReminderResponse updateReminder(Long cropId, Long reminderId, ReminderRequest request, User currentUser) {
        Reminder reminder = findReminder(cropId, reminderId, currentUser);

        if (request.getTitle() != null && !request.getTitle().isBlank()) {
            reminder.setTitle(request.getTitle().trim());
        }
        if (request.getType() != null) reminder.setType(request.getType());
        if (request.getReminderAt() != null) reminder.setReminderAt(request.getReminderAt());
        if (request.getEnabled() != null) reminder.setEnabled(request.getEnabled());
        if (request.getAiRecommended() != null) reminder.setAiRecommended(request.getAiRecommended());
        if (request.getCompleted() != null) reminder.setCompleted(request.getCompleted());
        if (request.getNote() != null) reminder.setNote(request.getNote());

        return new ReminderResponse(reminderRepository.save(reminder));
    }

    public void deleteReminder(Long cropId, Long reminderId, User currentUser) {
        reminderRepository.delete(findReminder(cropId, reminderId, currentUser));
    }

    private Crop findCrop(Long cropId, User currentUser) {
        return cropRepository
            .findByIdAndUserId(cropId, currentUser.getId())
            .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Crop not found"));
    }

    private Reminder findReminder(Long cropId, Long reminderId, User currentUser) {
        return reminderRepository
            .findByIdAndCropIdAndCropUserId(reminderId, cropId, currentUser.getId())
            .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Reminder not found"));
    }
}
