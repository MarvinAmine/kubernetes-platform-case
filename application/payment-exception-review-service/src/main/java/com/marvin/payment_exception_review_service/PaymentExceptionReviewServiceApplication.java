package com.marvin.payment_exception_review_service;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.properties.EnableConfigurationProperties;

import com.marvin.payment_exception_review_service.config.AppProperties;

@SpringBootApplication
@EnableConfigurationProperties(AppProperties.class)
public class PaymentExceptionReviewServiceApplication {

	public static void main(String[] args) {
		SpringApplication.run(PaymentExceptionReviewServiceApplication.class, args);
	}

}
