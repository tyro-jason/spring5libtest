package com.example.spring5app.controller;

import com.example.shared.entity.SharedNote;
import com.example.shared.service.SharedService;
import com.example.spring5app.repository.Spring5NoteRepository;
import org.hibernate.Version;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * REST controller that uses the shared library service
 */
@RestController
@RequestMapping("/api")
public class Spring5Controller {

    private final SharedService sharedService;
    private final Spring5NoteRepository noteRepository;

    @Autowired
    public Spring5Controller(SharedService sharedService, Spring5NoteRepository noteRepository) {
        this.sharedService = sharedService;
        this.noteRepository = noteRepository;
    }

    @GetMapping("/hello")
    public Map<String, Object> hello() {
        Map<String, Object> response = new HashMap<>();
        response.put("message", sharedService.getMessage());
        response.put("springVersion", sharedService.getSpringVersion());
        response.put("serviceInitialized", sharedService.isInitialized());
        response.put("application", "Spring 5 App");
        response.put("jakartaPostConstructWorking", sharedService.isInitialized());
        return response;
    }

    @GetMapping("/hibernate")
    @Transactional
    public Map<String, Object> hibernate(@RequestParam(name = "message", defaultValue = "from-spring5") String message) {
        SharedNote saved = noteRepository.save(new SharedNote(message));

        Map<String, Object> response = new HashMap<>();
        response.put("application", "Spring 5 App");
        response.put("hibernateVersion", Version.getVersionString());
        response.put("entityClass", SharedNote.class.getName());
        response.put("entityAnnotation", Arrays.stream(SharedNote.class.getAnnotations())
                .map(annotation -> annotation.annotationType().getName())
                .filter(name -> name.endsWith(".Entity"))
                .findFirst()
                .orElse("Entity annotation not found"));
        response.put("savedId", saved.getId());
        response.put("savedMessage", saved.getMessage());
        response.put("totalRows", noteRepository.count());
        response.put("latestMessages", noteRepository.findTop5ByOrderByIdDesc().stream()
                .map(SharedNote::getMessage)
                .collect(Collectors.toList()));
        return response;
    }
}