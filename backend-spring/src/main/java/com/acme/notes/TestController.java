package com.acme.notes;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/test")
public class TestController {
    
    @GetMapping("/public")
    public String publicEndpoint() {
        return "Public endpoint works!";
    }
    
    @GetMapping("/secure")
    public String secureEndpoint() {
        return "Secure endpoint works!";
    }
}