#!/usr/bin/env bash
set -euo pipefail

APP_NAMESPACE="${APP_NAMESPACE:-payment-exception-review-local}"
POSTGRES_DEPLOYMENT_NAME="${POSTGRES_DEPLOYMENT_NAME:-payment-review-postgres}"
POSTGRES_SERVICE_NAME="${POSTGRES_SERVICE_NAME:-payment-review-postgres}"
POSTGRES_DATABASE_NAME="${POSTGRES_DATABASE_NAME:-payment_exception_review}"
POSTGRES_LOCAL_USERNAME="${POSTGRES_LOCAL_USERNAME:-postgres}"

kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ${POSTGRES_DEPLOYMENT_NAME}
  namespace: ${APP_NAMESPACE}
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ${POSTGRES_DEPLOYMENT_NAME}
  template:
    metadata:
      labels:
        app: ${POSTGRES_DEPLOYMENT_NAME}
    spec:
      containers:
        - name: postgres
          image: postgres:16
          ports:
            - containerPort: 5432
          env:
            - name: POSTGRES_DB
              value: ${POSTGRES_DATABASE_NAME}
            - name: POSTGRES_USER
              value: ${POSTGRES_LOCAL_USERNAME}
            - name: POSTGRES_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: payment-review-db
                  key: POSTGRES_ADMIN_PASSWORD
---
apiVersion: v1
kind: Service
metadata:
  name: ${POSTGRES_SERVICE_NAME}
  namespace: ${APP_NAMESPACE}
spec:
  selector:
    app: ${POSTGRES_DEPLOYMENT_NAME}
  ports:
    - port: 5432
      targetPort: 5432
EOF

kubectl rollout status deployment/"$POSTGRES_DEPLOYMENT_NAME" -n "$APP_NAMESPACE" --timeout=180s
