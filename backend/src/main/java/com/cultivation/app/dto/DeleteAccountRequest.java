package com.cultivation.app.dto;

/**
 * Proof that the person holding the session is the account owner: the
 * password, or for a Google-only account a fresh Google ID token. A stolen
 * access token alone must not be enough to erase someone's records.
 */
public class DeleteAccountRequest {

    private String password;
    private String googleCredential;

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    public String getGoogleCredential() { return googleCredential; }
    public void setGoogleCredential(String googleCredential) { this.googleCredential = googleCredential; }
}
