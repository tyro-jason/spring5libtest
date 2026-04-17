package com.example.spring6app.controller;

import com.example.shared.entity.SharedNote;
import com.example.shared.service.SharedService;
import com.example.spring6app.repository.Spring6NoteRepository;
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
public class Spring6Controller {

    private final SharedService sharedService;
    private final Spring6NoteRepository noteRepository;

    @Autowired
    public Spring6Controller(SharedService sharedService, Spring6NoteRepository noteRepository) {
        this.sharedService = sharedService;
        this.noteRepository = noteRepository;
    }

    @GetMapping("/hello")
    public Map<String, Object> hello() {
        Map<String, Object> response = new HashMap<>();
        response.put("message", sharedService.getMessage());
        response.put("springVersion", sharedService.getSpringVersion());
        response.put("serviceInitialized", sharedService.isInitialized());
        response.put("application", "Spring 6 App");
        response.put("jakartaPostConstructWorking", sharedService.isInitialized());
        return response;
    }

    @GetMapping("/hibernate")
    @Transactional
    public Map<String, Object> hibernate(@RequestParam(name = "message", defaultValue = "from-spring6") String message) {
        SharedNote saved = noteRepository.save(new SharedNote(message));

        Map<String, Object> response = new HashMap<>();
        response.put("application", "Spring 6 App");
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