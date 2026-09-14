package com.cultivation.app.dto;

public class AiAskResponse {

    private final String answer;

    public AiAskResponse(String answer) {
        this.answer = answer;
    }

    public String getAnswer() { return answer; }
}
