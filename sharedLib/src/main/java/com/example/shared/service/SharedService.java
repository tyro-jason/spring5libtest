package com.example.shared.service;

import jakarta.annotation.PostConstruct;
import jakarta.annotation.PreDestroy;
import jakarta.inject.Named;
import org.springframework.stereotype.Component;

/**
 * A shared service component that works with both Spring 5 and Spring 6.
 * Uses Jakarta annotations for lifecycle management and Spring annotations for dependency injection.
 */
@Component
@Named("sharedService")
public class SharedService {

    private boolean initialized = false;

    @PostConstruct
    public void init() {
        this.initialized = true;
        System.out.println("SharedService initialized - Jakarta PostConstruct called");
    }

    @PreDestroy
    public void cleanup() {
        this.initialized = false;
        System.out.println("SharedService cleanup - Jakarta PreDestroy called");
    }

    public String getMessage() {
        return initialized ? "Hello from Shared Library! This works with both Spring 5 and Spring 6" 
                          : "Service not initialized";
    }

    public String getSpringVersion() {
        try {
            // Check if we can detect Spring version at runtime
            Class<?> springVersionClass = Class.forName("org.springframework.core.SpringVersion");
            return (String) springVersionClass.getMethod("getVersion").invoke(null);
        } catch (Exception e) {
            return "Unknown Spring version";
        }
    }

    public boolean isInitialized() {
        return initialized;
    }
}