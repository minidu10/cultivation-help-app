package com.cultivation.app.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.MailException;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

@Service
public class MailService {

    private static final Logger log = LoggerFactory.getLogger(MailService.class);

    private final JavaMailSender mailSender;
    private final String from;
    private final int codeTtlMinutes;

    public MailService(JavaMailSender mailSender,
                       @Value("${app.mail.from}") String from,
                       @Value("${app.verification.code-ttl-minutes}") int codeTtlMinutes) {
        this.mailSender = mailSender;
        this.from = from;
        this.codeTtlMinutes = codeTtlMinutes;
    }

    /**
     * Sent synchronously: the user is staring at the screen waiting for this
     * code, so a delivery failure has to surface as an error rather than
     * disappearing into a background thread.
     */
    public void sendVerificationCode(String to, String code) {
        send(to,
            "Your AgroMaster verification code",
            """
            Your AgroMaster verification code is:

                %s

            Enter it on the registration page to continue.
            The code expires in %d minutes.

            If you did not request this, you can ignore this email.
            """.formatted(code, codeTtlMinutes));
    }

    public void sendPasswordResetCode(String to, String code) {
        send(to,
            "Reset your AgroMaster password",
            """
            We received a request to reset your AgroMaster password.

            Your reset code is:

                %s

            The code expires in %d minutes.

            If you did not request a password reset, ignore this email -
            your password has not been changed.
            """.formatted(code, codeTtlMinutes));
    }

    /**
     * Fire-and-forget: nothing depends on it, so a failure is logged rather
     * than failing a registration that already succeeded.
     */
    @Async
    public void sendWelcome(String to, String fullName) {
        try {
            send(to,
                "Welcome to AgroMaster",
                """
                Hello %s,

                Your AgroMaster account has been created successfully.

                You can now track your crops, log expenses and harvests,
                see your profit and loss, and get AI advice for your farm.

                Reminders you set will be sent to this email address.

                -- AgroMaster
                """.formatted(fullName));
        } catch (RuntimeException ex) {
            log.warn("Welcome email to {} failed: {}", to, ex.getMessage());
        }
    }

    /**
     * One digest per farmer per day rather than one email per reminder -
     * a farmer with five tasks tomorrow gets a single message, not five.
     * Synchronous: the scheduler records what was sent only if this returns,
     * so a failure must propagate rather than vanish on another thread.
     */
    public void sendReminderDigest(String to, String fullName, String body, int taskCount) {
        String subject = taskCount == 1
            ? "1 farm task coming up"
            : taskCount + " farm tasks coming up";
        send(to, subject, """
            Hello %s,

            %s
            -- AgroMaster
            """.formatted(fullName, body));
    }

    private void send(String to, String subject, String body) {
        SimpleMailMessage message = new SimpleMailMessage();
        message.setFrom(from);
        message.setTo(to);
        message.setSubject(subject);
        message.setText(body);
        try {
            mailSender.send(message);
            log.debug("Sent '{}' to {}", subject, to);
        } catch (MailException ex) {
            log.error("Failed sending '{}' to {}: {}", subject, to, ex.getMessage());
            throw ex;
        }
    }
}
