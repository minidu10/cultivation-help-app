package com.cultivation.app.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

import com.cultivation.app.dto.AiAskRequest;
import com.cultivation.app.dto.AiAskResponse;
import com.cultivation.app.entity.User;
import com.cultivation.app.service.AiAdvisorService;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;

/**
 * Authenticated entry point to the AI advisor. The AI service itself is not
 * reachable from outside the compose network.
 */
@RestController
@RequestMapping("/api/ai")
@Tag(name = "AI Advisor", description = "Ask the farming advisor a question")
public class AiController {

    private final AiAdvisorService aiAdvisorService;

    public AiController(AiAdvisorService aiAdvisorService) {
        this.aiAdvisorService = aiAdvisorService;
    }

    @PostMapping("/ask")
    @Operation(summary = "Ask the AI advisor a farming question")
    public ResponseEntity<AiAskResponse> ask(@Valid @RequestBody AiAskRequest request,
                                             @AuthenticationPrincipal User currentUser) {
        String answer = aiAdvisorService.ask(request.getQuestion(), request.getCropContext(), currentUser);
        return ResponseEntity.ok(new AiAskResponse(answer));
    }

    @GetMapping("/health")
    @Operation(summary = "Whether the AI service is reachable and configured")
    public ResponseEntity<Map<String, Object>> health() {
        return ResponseEntity.ok(aiAdvisorService.health());
    }
}
