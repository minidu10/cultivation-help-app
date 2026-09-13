package com.cultivation.app.dto;

import jakarta.validation.constraints.NotBlank;

public class GoogleSignInRequest {

    /** The ID token issued by Google Identity Services in the browser. */
    @NotBlank(message = "Google credential is required")
    private String credential;

    public String getCredential() { return credential; }
    public void setCredential(String credential) { this.credential = credential; }
}
