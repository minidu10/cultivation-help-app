package com.cultivation.app.service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import com.cultivation.app.entity.Reminder;
import com.cultivation.app.entity.ReminderNotification;
import com.cultivation.app.entity.User;
import com.cultivation.app.repository.ReminderNotificationRepository;
import com.cultivation.app.repository.ReminderRepository;

/**
 * Emails farmers about reminders that are coming up, ahead of time.
 *
 * Two decisions shape this job:
 *
 *  - Notice is given in advance (two days out, then one day out) rather than
 *    at the moment a reminder falls due. A reminder to fertilise is useless
 *    the minute it is due; it is useful the day before.
 *
 *  - Everything a farmer needs to hear on a given day goes in ONE email.
 *    Sending per reminder floods the inbox on a busy week and trains people
 *    to ignore the mail entirely.
 *
 * Runs once a day rather than continuously, so at most one message per farmer
 * per day is possible by construction. The clock is the container clock,
 * pinned to Asia/Colombo via TZ in docker-compose.
 */
@Component
public class ReminderNotificationJob {

    private static final Logger log = LoggerFactory.getLogger(ReminderNotificationJob.class);
    private static final DateTimeFormatter DATE_FMT = DateTimeFormatter.ofPattern("EEE d MMM");
    private static final DateTimeFormatter TIME_FMT = DateTimeFormatter.ofPattern("h:mm a");

    private final ReminderRepository reminderRepository;
    private final ReminderNotificationRepository notificationRepository;
    private final MailService mailService;
    private final boolean enabled;
    private final List<Integer> leadDays;

    public ReminderNotificationJob(ReminderRepository reminderRepository,
                                   ReminderNotificationRepository notificationRepository,
                                   MailService mailService,
                                   @Value("${app.reminders.email-enabled:true}") boolean enabled,
                                   @Value("${app.reminders.lead-days:2,1}") List<Integer> leadDays) {
        this.reminderRepository = reminderRepository;
        this.notificationRepository = notificationRepository;
        this.mailService = mailService;
        this.enabled = enabled;
        // Descending, so the digest reads furthest-out first.
        this.leadDays = leadDays.stream().distinct().sorted(Comparator.reverseOrder()).toList();
    }

    @Scheduled(cron = "${app.reminders.cron:0 0 7 * * *}")
    @Transactional
    public void sendUpcomingDigests() {
        if (!enabled || leadDays.isEmpty()) {
            return;
        }

        LocalDate today = LocalDate.now();
        int maxLead = leadDays.get(0);
        int minLead = leadDays.get(leadDays.size() - 1);

        // Only the days an advance notice could land on are scanned.
        LocalDateTime from = today.plusDays(minLead).atStartOfDay();
        LocalDateTime to = today.plusDays(maxLead + 1L).atStartOfDay();

        List<Reminder> candidates = reminderRepository.findUpcoming(from, to).stream()
            .filter(r -> leadDays.contains(daysAhead(today, r)))
            .toList();

        if (candidates.isEmpty()) {
            return;
        }

        Set<String> alreadySent = new HashSet<>(notificationRepository.findSentKeys(
            candidates.stream().map(Reminder::getId).toList()));

        List<Reminder> toAnnounce = candidates.stream()
            .filter(r -> !alreadySent.contains(r.getId() + ":" + daysAhead(today, r)))
            .toList();

        if (toAnnounce.isEmpty()) {
            return;
        }

        // One message per owner, not per reminder.
        Map<User, List<Reminder>> byUser = toAnnounce.stream()
            .collect(Collectors.groupingBy(r -> r.getCrop().getUser(),
                     LinkedHashMap::new, Collectors.toList()));

        log.info("Sending {} reminder digest(s) covering {} reminder(s)",
                 byUser.size(), toAnnounce.size());

        for (Map.Entry<User, List<Reminder>> entry : byUser.entrySet()) {
            User user = entry.getKey();
            List<Reminder> reminders = entry.getValue();
            try {
                mailService.sendReminderDigest(
                    user.getEmail(),
                    user.getFullName(),
                    buildDigest(today, reminders),
                    reminders.size());

                // Recorded only after a successful send, so a mail failure is
                // retried tomorrow instead of being silently swallowed.
                notificationRepository.saveAll(reminders.stream()
                    .map(r -> new ReminderNotification(r.getId(), daysAhead(today, r)))
                    .toList());
            } catch (RuntimeException ex) {
                log.error("Reminder digest to {} failed: {}", user.getEmail(), ex.getMessage());
            }
        }
    }

    private static int daysAhead(LocalDate today, Reminder reminder) {
        return (int) ChronoUnit.DAYS.between(today, reminder.getReminderAt().toLocalDate());
    }

    /** Groups the reminders under a plain-language heading per day. */
    private String buildDigest(LocalDate today, List<Reminder> reminders) {
        Map<Integer, List<Reminder>> byLead = new LinkedHashMap<>();
        for (Integer lead : leadDays) {
            List<Reminder> forLead = reminders.stream()
                .filter(r -> daysAhead(today, r) == lead)
                .sorted(Comparator.comparing(Reminder::getReminderAt))
                .toList();
            if (!forLead.isEmpty()) {
                byLead.put(lead, forLead);
            }
        }

        List<String> sections = new ArrayList<>();
        // Nearest first: what happens tomorrow matters more than in two days.
        List<Integer> order = new ArrayList<>(byLead.keySet());
        Collections.reverse(order);

        for (Integer lead : order) {
            LocalDate date = today.plusDays(lead);
            StringBuilder section = new StringBuilder();
            section.append(heading(lead)).append(" (").append(date.format(DATE_FMT)).append(")\n");
            for (Reminder r : byLead.get(lead)) {
                section.append("  - ").append(r.getTitle())
                       .append(" - ").append(r.getCrop().getName())
                       .append(" at ").append(r.getReminderAt().format(TIME_FMT)).append('\n');
                if (r.getNote() != null && !r.getNote().isBlank()) {
                    section.append("    ").append(r.getNote().trim()).append('\n');
                }
            }
            sections.add(section.toString());
        }

        return String.join("\n", sections);
    }

    private static String heading(int leadDays) {
        return switch (leadDays) {
            case 0 -> "TODAY";
            case 1 -> "TOMORROW";
            case 2 -> "DAY AFTER TOMORROW";
            default -> "IN " + leadDays + " DAYS";
        };
    }
}
