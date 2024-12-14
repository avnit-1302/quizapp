package no.itszipzon.dto;

import java.time.LocalDateTime;

public class FriendDto {
    private Long friendId;
    private String username;
    private String status;
    private LocalDateTime createdAt;
    private LocalDateTime acceptedAt;
    private LocalDateTime lastLoggedIn;
    private String profilePicture;

    /**
     * Constructor matching the JPQL query parameters.
     */
    public FriendDto(Long friendId, String username, String status, LocalDateTime createdAt, 
    LocalDateTime acceptedAt, LocalDateTime lastLoggedIn, String profilePicture) {
    this.friendId = friendId;
    this.username = username;
    this.status = status;
    this.createdAt = createdAt;
    this.acceptedAt = acceptedAt;
    this.lastLoggedIn = lastLoggedIn;
    this.profilePicture = profilePicture;
}


    // Getters and Setters
    public Long getFriendId() {
        return friendId;
    }

    public void setFriendId(Long friendId) {
        this.friendId = friendId;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getAcceptedAt() {
        return acceptedAt;
    }

    public void setAcceptedAt(LocalDateTime acceptedAt) {
        this.acceptedAt = acceptedAt;
    }

    public LocalDateTime getLastLoggedIn() {
        return lastLoggedIn;
    }

    public void setLastLoggedIn(LocalDateTime lastLoggedIn) {
        this.lastLoggedIn = lastLoggedIn;
    }
    
    public String getProfilePicture() {
        return profilePicture;
    }

    public void setProfilePicture(String profilePicture) {
        this.profilePicture = profilePicture;
    }
}