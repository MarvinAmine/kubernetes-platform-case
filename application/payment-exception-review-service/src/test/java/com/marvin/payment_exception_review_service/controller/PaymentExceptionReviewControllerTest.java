  package com.marvin.payment_exception_review_service.controller;

  import com.marvin.payment_exception_review_service.dto.ServiceStatusResponse;
  import com.marvin.payment_exception_review_service.dto.ValidationMode;
  import
  com.marvin.payment_exception_review_service.service.PaymentExceptionReviewService;
  import org.junit.jupiter.api.Test;
  import org.springframework.beans.factory.annotation.Autowired;
  import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;

  import org.springframework.http.MediaType;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

  import static org.mockito.BDDMockito.given;
  import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
  import static
  org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
  import static
  org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

  @WebMvcTest(PaymentExceptionReviewController.class)
  class PaymentExceptionReviewControllerTest {

      @Autowired
      private MockMvc mockMvc;

      @MockitoBean
      private PaymentExceptionReviewService paymentExceptionReviewService;

      @Test
      void shouldReturnServiceStatus() throws Exception {
          ServiceStatusResponse response = ServiceStatusResponse.builder()
                  .service("payment-exception-review-service")
                  .version("0.0.1-SNAPSHOT")
                  .environmentName("stage1")
                  .infrastructureOwner("infrastructure-team")
                  .platformOwner("platform-team")
                  .validationMode(ValidationMode.STANDARD)
                  .escalationEnabled(true)
                  .riskAmountThreshold(10000)
                  .region("CA-QC")
                  .logLevel("INFO")
                  .build();

          given(paymentExceptionReviewService.getServiceStatus()).willReturn(response);

          mockMvc.perform(get("/api/payment-exceptions/service-status")
                          .accept(MediaType.APPLICATION_JSON))
                  .andExpect(status().isOk())
                  .andExpect(jsonPath("$.service").value("payment-exception-review-service"))
                  .andExpect(jsonPath("$.version").value("0.0.1-SNAPSHOT"))
                  .andExpect(jsonPath("$.environmentName").value("stage1"))
                  .andExpect(jsonPath("$.infrastructureOwner").value("infrastructure-team"))
                  .andExpect(jsonPath("$.platformOwner").value("platform-team"))
                  .andExpect(jsonPath("$.validationMode").value("STANDARD"))
                  .andExpect(jsonPath("$.escalationEnabled").value(true))
                  .andExpect(jsonPath("$.riskAmountThreshold").value(10000))
                  .andExpect(jsonPath("$.region").value("CA-QC"))
                  .andExpect(jsonPath("$.logLevel").value("INFO"));
      }
  }
