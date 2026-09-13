package com.cultivation.app.repository;

import java.time.LocalDateTime;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.cultivation.app.entity.EmailVerification;
import com.cultivation.app.entity.EmailVerification.Purpose;

@Repository
public interface EmailVerificationRepository extends JpaRepository<EmailVerification, Long> {

    /** The newest code issued for this email and purpose, whatever its state. */
    Optional<EmailVerification> findFirstByEmailAndPurposeOrderByCreatedAtDesc(String email, Purpose purpose);

    /**
     * A verification that has been confirmed but not yet spent, and is still
     * inside its completion window. This is what register() and resetPassword()
     * require before they will do anything.
     */
    @Query("""
           SELECT v FROM EmailVerification v
            WHERE v.email = :email
              AND v.purpose = :purpose
              AND v.verifiedAt IS NOT NULL
              AND v.consumedAt IS NULL
              AND v.verifiedAt >= :notBefore
            ORDER BY v.verifiedAt DESC
            LIMIT 1
           """)
    Optional<EmailVerification> findUsableVerification(@Param("email") String email,
                                                       @Param("purpose") Purpose purpose,
                                                       @Param("notBefore") LocalDateTime notBefore);

    /** Retires any outstanding codes so only the newest one can ever be used. */
    @Modifying
    @Query("""
           UPDATE EmailVerification v
              SET v.consumedAt = CURRENT_TIMESTAMP
            WHERE v.email = :email
              AND v.purpose = :purpose
              AND v.consumedAt IS NULL
           """)
    void consumeOutstanding(@Param("email") String email, @Param("purpose") Purpose purpose);
}
