package com.cultivation.app.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.jdbc.core.simple.JdbcClient;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.cultivation.app.entity.User;

/**
 * Erases a farmer and everything they recorded, in one transaction.
 *
 * Children are deleted explicitly, deepest first, rather than relying on
 * ON DELETE CASCADE. Older databases were baselined from schemas Hibernate
 * created, whose foreign keys may not cascade, and a half-deleted account is
 * worse than a failed delete. Any new table holding user data must be added
 * here; AccountDeletionIntegrationTest checks that nothing is left behind.
 */
@Service
public class AccountDeletionService {

    private static final Logger log = LoggerFactory.getLogger(AccountDeletionService.class);

    private static final String USER_CROPS = "SELECT id FROM crops WHERE user_id = :userId";

    private final JdbcClient jdbc;

    public AccountDeletionService(JdbcClient jdbc) {
        this.jdbc = jdbc;
    }

    @Transactional
    public void deleteEverything(User user) {
        Long userId = user.getId();

        delete("DELETE FROM reminder_notifications WHERE reminder_id IN "
             + "(SELECT id FROM reminders WHERE crop_id IN (" + USER_CROPS + "))", userId);
        delete("DELETE FROM reminders WHERE crop_id IN (" + USER_CROPS + ")", userId);
        delete("DELETE FROM crop_insights WHERE crop_id IN (" + USER_CROPS + ")", userId);
        delete("DELETE FROM expenses WHERE crop_id IN (" + USER_CROPS + ")", userId);
        delete("DELETE FROM harvests WHERE crop_id IN (" + USER_CROPS + ")", userId);
        delete("DELETE FROM crops WHERE user_id = :userId", userId);
        delete("DELETE FROM refresh_tokens WHERE user_id = :userId", userId);

        jdbc.sql("DELETE FROM email_verifications WHERE email = :email")
            .param("email", user.getEmail())
            .update();
        delete("DELETE FROM users WHERE id = :userId", userId);

        log.info("Deleted account {} and all of its data", userId);
    }

    private void delete(String sql, Long userId) {
        jdbc.sql(sql).param("userId", userId).update();
    }
}
