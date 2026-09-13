package com.cultivation.app.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.cultivation.app.entity.ReminderNotification;

@Repository
public interface ReminderNotificationRepository extends JpaRepository<ReminderNotification, Long> {

    /**
     * Which (reminder, lead) notices among the candidates have already gone out.
     * Fetched in one query rather than per reminder so a busy day costs one
     * round trip instead of dozens.
     */
    @Query("""
           SELECT CONCAT(n.reminderId, ':', n.leadDays)
             FROM ReminderNotification n
            WHERE n.reminderId IN :reminderIds
           """)
    List<String> findSentKeys(@Param("reminderIds") List<Long> reminderIds);
}
