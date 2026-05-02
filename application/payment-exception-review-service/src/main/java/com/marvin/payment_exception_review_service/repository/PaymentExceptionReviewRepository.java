package com.marvin.payment_exception_review_service.repository;

import java.util.Optional;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import com.marvin.payment_exception_review_service.entity.PaymentExceptionReviewEntity;


public interface PaymentExceptionReviewRepository  extends JpaRepository<PaymentExceptionReviewEntity, UUID>{
    Optional<PaymentExceptionReviewEntity> findByReviewId(String reviewId);
}
