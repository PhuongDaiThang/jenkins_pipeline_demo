package com.example.jenkinsdemo;

import java.time.Instant;

public record HelloResponse(String message, String source, Instant time) {
}
