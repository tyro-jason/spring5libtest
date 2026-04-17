package com.example.spring5app;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.domain.EntityScan;

/**
 * Spring Boot 2.7.x Application (uses Spring 5.3.x)
 */
@SpringBootApplication
@EntityScan(basePackages = "com.example.shared.entity")
public class Spring5Application {

    public static void main(String[] args) {
        System.out.println("Starting Spring 5 Application...");
        SpringApplication.run(Spring5Application.class, args);
    }
}