package com.cultivation.app.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import com.cultivation.app.entity.DeviceToken;

@Repository
public interface DeviceTokenRepository extends JpaRepository<DeviceToken, Long> {

    Optional<DeviceToken> findByToken(String token);

    List<DeviceToken> findByUserId(Long userId);

    @Modifying
    @Transactional
    @Query("DELETE FROM DeviceToken d WHERE d.token = :token")
    int deleteByToken(@Param("token") String token);

    @Modifying
    @Transactional
    @Query("DELETE FROM DeviceToken d WHERE d.token = :token AND d.user.id = :userId")
    int deleteByTokenAndUserId(@Param("token") String token, @Param("userId") Long userId);
}
