#!/bin/bash

# Find the container ID for the Payment Service Proxy instance
PROXY_CONTAINER_ID=$(docker ps --filter "name=paymentservice" --format "{{.ID}}")

# Check if the Payment Service Proxy container was found
if [ -z "$PROXY_CONTAINER_ID" ]; then
  echo "Error: Could not find the Payment Service Proxy container."
  exit 1
fi

# Define the destination paths for the copied files
LOCAL_CERT_PATH="./proxy-tls.cert"
LOCAL_MACAROON_PATH="./proxy-admin.macaroon"

# Copy the tls.cert and admin.macaroon from the Payment Service Proxy container
docker cp "${PROXY_CONTAINER_ID}:/paymentservice/tls.cert" "${LOCAL_CERT_PATH}"
docker cp "${PROXY_CONTAINER_ID}:/paymentservice/admin.macaroon" "${LOCAL_MACAROON_PATH}"

# Confirm success
if [ -f "${LOCAL_CERT_PATH}" ] && [ -f "${LOCAL_MACAROON_PATH}" ]; then
  echo "Successfully copied proxy-tls.cert and proxy-admin.macaroon to the local filesystem."
else
  echo "Error: Failed to copy files."
fi
