package com.marvin.payment_exception_review_service.dto;

import lombok.Builder;
import lombok.Value;

@Value
@Builder
public class ErrorResponse {
    String error;
    String message;
}
