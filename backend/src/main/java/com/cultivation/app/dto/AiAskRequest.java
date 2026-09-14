package com.cultivation.app.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public class AiAskRequest {

    @NotBlank(message = "Question cannot be empty")
    @Size(max = 1000, message = "Question is too long")
    private String question;

    @Size(max = 2000)
    private String cropContext;

    public String getQuestion() { return question; }
    public void setQuestion(String question) { this.question = question; }

    public String getCropContext() { return cropContext; }
    public void setCropContext(String cropContext) { this.cropContext = cropContext; }
}
