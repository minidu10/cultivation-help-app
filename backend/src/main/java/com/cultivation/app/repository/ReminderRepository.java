package com.cultivation.app.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.cultivation.app.entity.Reminder;

@Repository
public interface ReminderRepository extends JpaRepository<Reminder, Long> {

    List<Reminder> findByCropIdAndCropUserIdOrderByReminderAtAsc(Long cropId, Long userId);

    List<Reminder> findByCropUserIdAndEnabledTrueAndCompletedFalseAndReminderAtLessThanEqualOrderByReminderAtAsc(Long userId, java.time.LocalDateTime now);

    Optional<Reminder> findByIdAndCropUserId(Long reminderId, Long userId);

    void deleteByCropIdAndCropUserId(Long cropId, Long userId);
}
