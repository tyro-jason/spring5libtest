package com.example.shared.service;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

class SharedServiceTest {

    private SharedService sharedService;

    @BeforeEach
    void setUp() {
        sharedService = new SharedService();
    }

    @Test
    void testServiceInitialization() {
        assertFalse(sharedService.isInitialized());
        assertEquals("Service not initialized", sharedService.getMessage());
        
        sharedService.init();
        
        assertTrue(sharedService.isInitialized());
        assertEquals("Hello from Shared Library! This works with both Spring 5 and Spring 6", 
                     sharedService.getMessage());
    }

    @Test
    void testServiceCleanup() {
        sharedService.init();
        assertTrue(sharedService.isInitialized());
        
        sharedService.cleanup();
        assertFalse(sharedService.isInitialized());
    }
}