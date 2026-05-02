package com.marvin.payment_exception_review_service.dto;

import lombok.Builder;
import lombok.Value;

@Value
@Builder
public class ServiceStatusResponse {
    String service;
    String version;
    String environmentName;
    String infrastructureOwner;
    String platformOwner;
    ValidationMode validationMode;
    boolean escalationEnabled;
    int riskAmountThreshold;
    String region;
    String logLevel;
}
