package com.crm.exception;
import org.springframework.http.*;
import org.springframework.web.bind.annotation.*;
import java.time.Instant;
import java.util.*;
@RestControllerAdvice
public class GlobalExceptionHandler {
    @ExceptionHandler(ResourceNotFoundException.class)
    public ResponseEntity<Map<String,Object>> notFound(ResourceNotFoundException ex) {
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(error(404, ex.getMessage()));
    }
    @ExceptionHandler(DuplicateEmailException.class)
    public ResponseEntity<Map<String,Object>> duplicateEmail(DuplicateEmailException ex) {
        return ResponseEntity.status(HttpStatus.CONFLICT).body(error(409, ex.getMessage()));
    }
    @ExceptionHandler(InvalidCredentialsException.class)
    public ResponseEntity<Map<String,Object>> invalidCredentials(InvalidCredentialsException ex) {
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(error(401, ex.getMessage()));
    }
    @ExceptionHandler(Exception.class)
    public ResponseEntity<Map<String,Object>> generic(Exception ex) {
        return ResponseEntity.status(500).body(error(500, "Internal server error: " + ex.getMessage()));
    }
    private Map<String,Object> error(int status, String message) {
        Map<String,Object> m = new LinkedHashMap<>();
        m.put("timestamp", Instant.now()); m.put("status", status); m.put("message", message);
        return m;
    }
}
