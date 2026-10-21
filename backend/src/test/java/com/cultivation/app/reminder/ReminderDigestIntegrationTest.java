package com.cultivation.app.reminder;

import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.contains;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.Map;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.TestPropertySource;

import com.cultivation.app.service.ReminderNotificationJob;
import com.cultivation.app.support.IntegrationTest;

@TestPropertySource(properties = {
    "app.reminders.email-enabled=true",
    "app.reminders.lead-days=2,1"
})
class ReminderDigestIntegrationTest extends IntegrationTest {

    @Autowired
    private ReminderNotificationJob job;

    @Test
    void aReminderTomorrowIsMailedOnceEvenIfTheJobRunsTwice() throws Exception {
        Session session = register();
        long crop = createCrop(session, "Paddy");
        addReminder(session, crop, tomorrowAt("09:00:00"));

        job.sendUpcomingDigests();
        job.sendUpcomingDigests();

        verify(mailService, times(1)).sendReminderDigest(
            eq(session.email()), anyString(), contains("Apply fertilizer"), eq(1));
    }

    @Test
    void remindersForOneFarmerArriveInASingleDigest() throws Exception {
        Session session = register();
        long paddy = createCrop(session, "Paddy");
        long chilli = createCrop(session, "Chilli");
        addReminder(session, paddy, tomorrowAt("07:00:00"));
        addReminder(session, chilli, tomorrowAt("16:00:00"));

        job.sendUpcomingDigests();

        verify(mailService, times(1)).sendReminderDigest(eq(session.email()), anyString(), anyString(), eq(2));
    }

    @Test
    void farmersWhoOptedOutGetNothing() throws Exception {
        Session session = register();
        putAs(session, "/api/users/me", Map.of("reminderEmailsEnabled", false)).andExpect(status().isOk());
        long crop = createCrop(session, "Paddy");
        addReminder(session, crop, tomorrowAt("09:00:00"));

        job.sendUpcomingDigests();

        verify(mailService, never()).sendReminderDigest(eq(session.email()), anyString(), anyString(), anyInt());
    }

    @Test
    void completedRemindersAreNotAnnounced() throws Exception {
        Session session = register();
        long crop = createCrop(session, "Paddy");
        long reminder = addReminder(session, crop, tomorrowAt("09:00:00"));
        putAs(session, "/api/crops/" + crop + "/reminders/" + reminder, Map.of("completed", true))
            .andExpect(status().isOk());

        job.sendUpcomingDigests();

        verify(mailService, never()).sendReminderDigest(eq(session.email()), anyString(), anyString(), anyInt());
    }

    private static String tomorrowAt(String time) {
        return LocalDate.now().plusDays(1).format(DateTimeFormatter.ISO_LOCAL_DATE) + "T" + time;
    }
}
