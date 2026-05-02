package com.marvin.payment_exception_review_service.dto;

import lombok.Builder;
import lombok.Value;

@Value
@Builder
public class ConfigCheckResponse {
    ValidationState status;
    ValidationMode validationMode;
    boolean escalationEnabled;
    int riskAmountThreshold;
    String region;
    String environmentName;
}
