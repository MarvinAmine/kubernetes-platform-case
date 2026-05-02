package com.marvin.payment_exception_review_service.dto;

public enum ReasonCode {
    AMOUNT_THRESHOLD_EXCEEDED,
    MISSING_REFERENCE,
    DUPLICATE_SUSPECTED,
    DESTINATION_BLOCKED,
    COMPLIANCE_REVIEW_REQUIRED,
    INVALID_METADATA
}
