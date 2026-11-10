package com.cultivation.app.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.cultivation.app.entity.Reminder;

@Repository
public interface ReminderRepository extends JpaRepository<Reminder, Long> {

    List<Reminder> findByCropIdAndCropUserIdOrderByReminderAtAsc(Long cropId, Long userId);

    List<Reminder> findByCropUserIdAndEnabledTrueAndCompletedFalseAndReminderAtLessThanEqualOrderByReminderAtAsc(Long userId, java.time.LocalDateTime now);

    Optional<Reminder> findByIdAndCropUserId(Long reminderId, Long userId);

    /** Scoped to the crop in the URL as well as the owner, so a path cannot name the wrong crop. */
    Optional<Reminder> findByIdAndCropIdAndCropUserId(Long reminderId, Long cropId, Long userId);

    /** Active reminders inside a window, for one farmer, soonest first. */
    @Query("""
           SELECT r FROM Reminder r
             JOIN FETCH r.crop c
            WHERE c.user.id = :userId
              AND r.enabled = TRUE
              AND r.completed = FALSE
              AND r.reminderAt > :from
              AND r.reminderAt <= :to
            ORDER BY r.reminderAt ASC
           """)
    List<Reminder> findActiveForUserBetween(@Param("userId") Long userId,
                                            @Param("from") java.time.LocalDateTime from,
                                            @Param("to") java.time.LocalDateTime to);

    void deleteByCropIdAndCropUserId(Long cropId, Long userId);

    /**
     * Active reminders falling inside the advance-notice window, oldest first.
     * Farmers who switched reminder emails off are included: they may still
     * get the same digest as a push notification on their phone.
     * Crop and user are fetched eagerly: the digest is grouped by owner and
     * would otherwise fire a query per reminder to find the email address.
     */
    @Query("""
           SELECT r FROM Reminder r
             JOIN FETCH r.crop c
             JOIN FETCH c.user u
            WHERE r.enabled = TRUE
              AND r.completed = FALSE
              AND r.reminderAt >= :from
              AND r.reminderAt < :to
            ORDER BY r.reminderAt ASC
           """)
    List<Reminder> findUpcoming(@Param("from") java.time.LocalDateTime from,
                                @Param("to") java.time.LocalDateTime to);
}
