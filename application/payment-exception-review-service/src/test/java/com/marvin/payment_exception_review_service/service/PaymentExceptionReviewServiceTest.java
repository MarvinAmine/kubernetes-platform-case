package com.marvin.payment_exception_review_service.service;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.mock;

import org.springframework.test.util.ReflectionTestUtils;

import com.marvin.payment_exception_review_service.config.AppProperties;
import com.marvin.payment_exception_review_service.dto.ServiceStatusResponse;
import com.marvin.payment_exception_review_service.dto.ValidationMode;
import com.marvin.payment_exception_review_service.repository.PaymentExceptionReviewRepository;

public class PaymentExceptionReviewServiceTest {

    private PaymentExceptionReviewService paymentExceptionReviewService;
    private PaymentExceptionReviewRepository paymentExceptionReviewRepository;

    private final String SERVICE_NAME = "payment-exception-review-service";
    private final String APPLICATION_NAME = "0.0.1-SNAPSHOT" ;

    @BeforeEach
    void setUp() {
        AppProperties appProperties = new AppProperties();
        appProperties.setEnvironmentName("stage1");
        appProperties.setInfrastructureOwner("infrastructure-team");
        appProperties.setPlatformOwner("platform-team");
        appProperties.setValidationMode(ValidationMode.STANDARD);
        appProperties.setEscalationEnabled(true);
        appProperties.setRiskAmountThreshold(10000);
        appProperties.setRegion("CA-QC");
        appProperties.setLogLevel("INFO");
        paymentExceptionReviewRepository = mock(PaymentExceptionReviewRepository.class);

        paymentExceptionReviewService = new PaymentExceptionReviewService(
            appProperties,
            paymentExceptionReviewRepository
        );

        ReflectionTestUtils.setField(paymentExceptionReviewService, "serviceName",SERVICE_NAME);
        ReflectionTestUtils.setField(paymentExceptionReviewService, "applicationVersion", APPLICATION_NAME);
    }

    @Test
    void shouldReturnServiceStatusFromConfiguredProperties() {
        // Arrange

        // Act
        ServiceStatusResponse response = paymentExceptionReviewService.getServiceStatus();

        // Assert
        assertThat(response.getService()).isEqualTo("payment-exception-review-service");
        assertThat(response.getVersion()).isEqualTo("0.0.1-SNAPSHOT");
        assertThat(response.getEnvironmentName()).isEqualTo("stage1");
        assertThat(response.getInfrastructureOwner()).isEqualTo("infrastructure-team");
        assertThat(response.getPlatformOwner()).isEqualTo("platform-team");
        assertThat(response.getValidationMode()).isEqualTo(ValidationMode.STANDARD);
        assertThat(response.isEscalationEnabled()).isTrue();
        assertThat(response.getRiskAmountThreshold()).isEqualTo(10000);
        assertThat(response.getRegion()).isEqualTo("CA-QC");
        assertThat(response.getLogLevel()).isEqualTo("INFO");
    }
}
