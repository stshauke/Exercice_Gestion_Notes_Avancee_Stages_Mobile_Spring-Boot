package com.acme.notes;

import org.springframework.boot.autoconfigure.domain.EntityScan;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
@EnableJpaRepositories(basePackages = "com.acme.notes")
@EntityScan(basePackages = "com.acme.notes")
public class BackendSpringApplication {

	public static void main(String[] args) {
		SpringApplication.run(BackendSpringApplication.class, args);
	}

}
