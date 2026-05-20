package com.example.jenkinsdemo;

import java.time.Instant;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HelloController {

    @GetMapping("/api/hello")
    public HelloResponse hello() {
        return new HelloResponse(
                "Hello from Spring Boot backend",
                "jenkins-demo-backend",
                Instant.now()
        );
    }

    @GetMapping("/api/health-simple")
    public String healthSimple() {
        return "OK";
    }
}
