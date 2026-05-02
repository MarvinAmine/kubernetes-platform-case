package com.marvin.payment_exception_review_service.controller;

import com.marvin.payment_exception_review_service.service.PaymentExceptionReviewService;

import jakarta.validation.constraints.NotBlank;

import com.marvin.payment_exception_review_service.dto.PaymentExceptionStatusResponse;
import com.marvin.payment_exception_review_service.dto.ServiceStatusResponse;

import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/payment-exceptions")
@RequiredArgsConstructor
@Validated
public class PaymentExceptionReviewController {
    private final PaymentExceptionReviewService paymentExceptionReviewService;

    @GetMapping("/service-status")
    public ServiceStatusResponse getServiceStatus() {
        return paymentExceptionReviewService.getServiceStatus();
    }

    @GetMapping("/{id}/status")
    public PaymentExceptionStatusResponse getPaymentExceptionStatus(@PathVariable("id") @NotBlank String id) {
        return paymentExceptionReviewService.getPaymentExceptionStatus(id);
    }
}
