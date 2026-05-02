package com.marvin.payment_exception_review_service.config;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.validation.annotation.Validated;

import com.marvin.payment_exception_review_service.dto.ValidationMode;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Validated
@ConfigurationProperties(prefix = "app")
public class AppProperties {
    
    @NotNull
    private ValidationMode validationMode = ValidationMode.STANDARD;

    private boolean escalationEnabled = true;

    @Min(1)
    private int riskAmountThreshold = 10000;

    @NotBlank
    private String region = "CA-QC";

    @NotBlank
    private String environmentName = "stage1";

    @NotBlank
    private String infrastructureOwner = "infrastructure-team";

    @NotBlank
    private String platformOwner = "platform-team";

    @NotBlank
    private String logLevel = "INFO";
}
