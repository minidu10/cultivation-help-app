package com.cultivation.app.service;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.client.HttpClientErrorException;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestTemplate;

import com.cultivation.app.entity.DeviceToken;
import com.cultivation.app.entity.User;
import com.cultivation.app.repository.DeviceTokenRepository;

/**
 * Sends push notifications through the FCM HTTP v1 API.
 *
 * Plain HTTPS with a service-account token rather than the firebase-admin
 * SDK: that SDK brings gRPC and a Firestore client this app would never use,
 * on a backend held to 640 MB. Sending is best effort; a failure is logged
 * and the email digest goes out regardless.
 */
@Service
public class PushService {

    private static final Logger log = LoggerFactory.getLogger(PushService.class);

    public record PushMessage(String title, String body, Map<String, String> data) {
    }

    private final DeviceTokenRepository devices;
    private final FcmAccessTokens tokens;
    private final RestTemplate restTemplate;
    private final String fcmBaseUrl;

    public PushService(DeviceTokenRepository devices,
                       FcmAccessTokens tokens,
                       @Qualifier("fcmRestTemplate") RestTemplate restTemplate,
                       @Value("${app.push.fcm-url:https://fcm.googleapis.com}") String fcmBaseUrl) {
        this.devices = devices;
        this.tokens = tokens;
        this.restTemplate = restTemplate;
        this.fcmBaseUrl = fcmBaseUrl;
    }

    public boolean isEnabled() {
        return tokens.isConfigured();
    }

    public boolean hasDevices(User user) {
        return isEnabled() && !devices.findByUserId(user.getId()).isEmpty();
    }

    /** Sends to every phone the farmer has registered. Returns how many accepted it. */
    public int sendToUser(User user, PushMessage message) {
        if (!isEnabled()) {
            return 0;
        }
        List<DeviceToken> targets = devices.findByUserId(user.getId());
        if (targets.isEmpty()) {
            return 0;
        }
        String accessToken = tokens.accessToken().orElse(null);
        if (accessToken == null) {
            return 0;
        }
        int delivered = 0;
        for (DeviceToken device : targets) {
            if (send(device.getToken(), message, accessToken)) {
                delivered++;
            }
        }
        return delivered;
    }

    private boolean send(String deviceToken, PushMessage message, String accessToken) {
        HttpHeaders headers = new HttpHeaders();
        headers.setBearerAuth(accessToken);
        headers.setContentType(MediaType.APPLICATION_JSON);

        Map<String, Object> notification = Map.of("title", message.title(), "body", message.body());
        Map<String, Object> payload = new LinkedHashMap<>();
        payload.put("token", deviceToken);
        payload.put("notification", notification);
        payload.put("data", message.data() == null ? Map.of() : message.data());
        // Shown on the reminders channel the app creates, with sound.
        payload.put("android", Map.of("priority", "HIGH",
                                      "notification", Map.of("channel_id", "reminders")));

        String url = fcmBaseUrl + "/v1/projects/" + tokens.projectId() + "/messages:send";
        try {
            restTemplate.postForEntity(url, new HttpEntity<>(Map.of("message", payload), headers), String.class);
            return true;
        } catch (HttpClientErrorException ex) {
            // The app was uninstalled or the token rotated: it will never
            // work again, so it is removed rather than retried every day.
            if (ex.getStatusCode() == HttpStatus.NOT_FOUND
                || (ex.getStatusCode() == HttpStatus.BAD_REQUEST && ex.getResponseBodyAsString().contains("INVALID_ARGUMENT"))) {
                devices.deleteByToken(deviceToken);
                log.info("Removed a push token FCM no longer accepts");
            } else {
                log.warn("FCM refused a push: {}", ex.getStatusCode());
            }
            return false;
        } catch (RestClientException ex) {
            log.warn("FCM unreachable: {}", ex.getMessage());
            return false;
        }
    }
}
