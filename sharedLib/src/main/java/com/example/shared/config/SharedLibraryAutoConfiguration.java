package com.example.shared.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.CommonAnnotationBeanPostProcessor;

/**
 * Auto-configuration class for the shared library.
 * This enables the shared components to be automatically discovered by Spring Boot applications.
 * Includes explicit Jakarta annotation processing for Spring 5 compatibility.
 */
@Configuration
@ComponentScan(basePackages = "com.example.shared")
public class SharedLibraryAutoConfiguration {
    
    public SharedLibraryAutoConfiguration() {
        System.out.println("SharedLibraryAutoConfiguration loaded");
    }

    /**
     * Ensure Jakarta annotations (@PostConstruct, @PreDestroy) work with Spring 5.
     * Spring 6 includes this automatically, but Spring 5 might need explicit configuration.
     */
    @Bean
    public static CommonAnnotationBeanPostProcessor commonAnnotationBeanPostProcessor() {
        CommonAnnotationBeanPostProcessor processor = new CommonAnnotationBeanPostProcessor();
        // This ensures Jakarta annotations are processed even in Spring 5
        return processor;
    }
}