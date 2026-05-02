package com.marvin.payment_exception_review_service.dto;

public enum PaymentReviewStatus {
    RECEIVED,
    VALIDATING,
    PENDING_REVIEW,
    APPROVED,
    REJECTED,
    ESCALATED,
    CLOSED
}
