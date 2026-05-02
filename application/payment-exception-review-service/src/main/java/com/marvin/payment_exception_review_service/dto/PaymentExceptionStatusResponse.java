package com.marvin.payment_exception_review_service.dto;

import lombok.Builder;
import lombok.Value;

@Value
@Builder
public class PaymentExceptionStatusResponse {
    String reviewId;
    PaymentReviewStatus status;
    ValidationMode validationMode;
    boolean escalationEnabled;
    String region;
}
