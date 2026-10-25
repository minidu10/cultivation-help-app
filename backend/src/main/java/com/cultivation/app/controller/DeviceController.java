package com.cultivation.app.controller;

import java.util.Map;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.cultivation.app.dto.DeviceRequest;
import com.cultivation.app.entity.DeviceToken;
import com.cultivation.app.entity.User;
import com.cultivation.app.exception.ApiException;
import com.cultivation.app.repository.DeviceTokenRepository;
import com.cultivation.app.repository.UserRepository;
import com.cultivation.app.service.PushService;
import com.cultivation.app.service.PushService.PushMessage;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;

@RestController
@RequestMapping("/api/devices")
@Tag(name = "Devices", description = "Phones that receive push notifications")
public class DeviceController {

    private final DeviceTokenRepository devices;
    private final UserRepository users;
    private final PushService pushService;

    public DeviceController(DeviceTokenRepository devices, UserRepository users, PushService pushService) {
        this.devices = devices;
        this.users = users;
        this.pushService = pushService;
    }

    /**
     * Registers this phone. Calling it again is harmless, and a token that
     * was registered to another account (the phone changed hands, or someone
     * else signed in on it) moves to the caller.
     */
    @PostMapping
    @Transactional
    @Operation(summary = "Register this phone for push notifications")
    public ResponseEntity<Void> register(@Valid @RequestBody DeviceRequest request,
                                         @AuthenticationPrincipal User currentUser) {
        User owner = users.getReferenceById(currentUser.getId());
        String platform = request.getPlatform().toLowerCase();
        DeviceToken device = devices.findByToken(request.getToken())
            .orElseGet(() -> new DeviceToken(owner, request.getToken(), platform));
        device.claim(owner, platform);
        devices.save(device);
        return ResponseEntity.noContent().build();
    }

    @DeleteMapping("/{token}")
    @Operation(summary = "Stop sending push notifications to this phone")
    public ResponseEntity<Void> unregister(@PathVariable String token, @AuthenticationPrincipal User currentUser) {
        devices.deleteByTokenAndUserId(token, currentUser.getId());
        return ResponseEntity.noContent().build();
    }

    /** One tap to check that Firebase is set up end to end. */
    @PostMapping("/test")
    @Operation(summary = "Send a test notification to my phones")
    public ResponseEntity<Map<String, Integer>> test(@AuthenticationPrincipal User currentUser) {
        if (!pushService.isEnabled()) {
            throw new ApiException(HttpStatus.SERVICE_UNAVAILABLE, "Push notifications are not configured on this server");
        }
        int sent = pushService.sendToUser(currentUser, new PushMessage(
            "AgroMaster is connected", "Reminders and weather warnings will arrive here.", Map.of("type", "test")));
        return ResponseEntity.ok(Map.of("sent", sent));
    }
}
