package com.example.spring6app;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.domain.EntityScan;

/**
 * Spring Boot 3.x Application (uses Spring 6.x)
 */
@SpringBootApplication
@EntityScan(basePackages = "com.example.shared.entity")
public class Spring6Application {

    public static void main(String[] args) {
        System.out.println("Starting Spring 6 Application...");
        SpringApplication.run(Spring6Application.class, args);
    }
}