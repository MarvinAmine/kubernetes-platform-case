CREATE TABLE payment_exception_reviews (
    id UUID PRIMARY KEY,
    review_id VARCHAR(64) NOT NULL UNIQUE,
    payment_reference VARCHAR(128) NOT NULL,
    status VARCHAR(32) NOT NULL,
    reason_code VARCHAR(64) NOT NULL,
    validation_state VARCHAR(32) NOT NULL,
    priority VARCHAR(16) NOT NULL,
    region VARCHAR(32) NOT NULL,
    source_system VARCHAR(64) NOT NULL,
    assigned_queue VARCHAR(64) NOT NULL,
    requires_manual_review BOOLEAN NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL
);

CREATE INDEX idx_payment_exception_reviews_status ON payment_exception_reviews (status);

CREATE INDEX idx_payment_exception_reviews_payment_reference ON payment_exception_reviews (payment_reference);