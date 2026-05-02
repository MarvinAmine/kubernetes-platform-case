package com.marvin.payment_exception_review_service.service;

import com.marvin.payment_exception_review_service.config.AppProperties;
import com.marvin.payment_exception_review_service.dto.PaymentExceptionStatusResponse;
import com.marvin.payment_exception_review_service.dto.ServiceStatusResponse;
import com.marvin.payment_exception_review_service.entity.PaymentExceptionReviewEntity;
import com.marvin.payment_exception_review_service.repository.PaymentExceptionReviewRepository;

import org.springframework.stereotype.Service;
import org.springframework.beans.factory.annotation.Value;
import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class PaymentExceptionReviewService {

    private final AppProperties appProperties;

    @Value("${spring.application.name}")
    private String serviceName;

    @Value("${application.version:0.0.1-SNAPSHOT}")
    private String applicationVersion;

    private final PaymentExceptionReviewRepository paymentExceptionReviewRepository;

    public ServiceStatusResponse getServiceStatus() {
        return ServiceStatusResponse.builder()
            .service(serviceName)
            .version(applicationVersion)
            .environmentName(appProperties.getEnvironmentName())
            .infrastructureOwner(appProperties.getInfrastructureOwner())
            .platformOwner(appProperties.getPlatformOwner())
            .validationMode(appProperties.getValidationMode())
            .escalationEnabled(appProperties.isEscalationEnabled())
            .riskAmountThreshold(appProperties.getRiskAmountThreshold())
            .region(appProperties.getRegion())
            .logLevel(appProperties.getLogLevel())
            .build();
    }

    public PaymentExceptionStatusResponse getPaymentExceptionStatus(String reviewId){
        PaymentExceptionReviewEntity review = paymentExceptionReviewRepository
        .findByReviewId(reviewId).orElseThrow(
            () -> new IllegalStateException("Payment exception review not found for reviewId=" + reviewId)
        );

        return PaymentExceptionStatusResponse.builder()
        .reviewId(review.getReviewId())
        .status(review.getStatus())
        .validationMode(appProperties.getValidationMode())
        .escalationEnabled(appProperties.isEscalationEnabled())
        .region(review.getRegion())
        .build();

    } 


    
}
