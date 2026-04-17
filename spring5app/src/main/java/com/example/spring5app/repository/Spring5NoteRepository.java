package com.example.spring5app.repository;

import com.example.shared.entity.SharedNote;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface Spring5NoteRepository extends JpaRepository<SharedNote, Long> {
    List<SharedNote> findTop5ByOrderByIdDesc();
}

