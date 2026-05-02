package com.marvin.payment_exception_review_service.entity;

import java.util.UUID;
import java.time.OffsetDateTime;

import com.marvin.payment_exception_review_service.dto.PaymentReviewStatus;
import com.marvin.payment_exception_review_service.dto.ReasonCode;
import com.marvin.payment_exception_review_service.dto.ValidationState;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(name = "payment_exception_reviews")
@Getter
@Setter
public class PaymentExceptionReviewEntity {

    @Id
    private UUID id;

    @Column(name = "review_id", nullable = false, unique = true, length = 64)
    private String reviewId;

    @Column(name = "payment_reference", nullable = false, length = 128)
    private String paymentReference;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false, length = 32)
    private PaymentReviewStatus status;

    @Enumerated(EnumType.STRING)
    @Column(name = "reason_code", nullable = false, length = 64)
    private ReasonCode reasonCode;

    @Enumerated(EnumType.STRING)
    @Column(name = "validation_state", nullable = false, length = 32)
    private ValidationState validationState;

    @Column(name = "priority", nullable = false, length = 16)
    private String priority;

    @Column(name = "region", nullable = false, length = 32)
    private String region;

    @Column(name = "source_system", nullable = false, length = 64)
    private String sourceSystem;

    @Column(name = "assigned_queue", nullable = false, length = 64)
    private String assignedQueue;

    @Column(name = "requires_manual_review", nullable = false)
    private Boolean requiresManualReview;

    @Column(name = "created_at", nullable = false)
    private OffsetDateTime createdAt;

    @Column(name = "updated_at", nullable = false)
    private OffsetDateTime updatedAt;
}