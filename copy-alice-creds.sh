#!/bin/bash

# Find the container ID for the Alice LND instance
ALICE_CONTAINER_ID=$(docker ps --filter "name=lightning-benchmark-lnd-alice-1" --format "{{.ID}}")

# Check if the Alice container was found
if [ -z "$ALICE_CONTAINER_ID" ]; then
  echo "Error: Could not find the Alice LND container."
  exit 1
fi

# Define the destination paths
LOCAL_CERT_PATH="./tls.cert"
LOCAL_MACAROON_PATH="./admin.macaroon"

# Copy the tls.cert and admin.macaroon from the Alice container
docker cp "${ALICE_CONTAINER_ID}:/cfg/tls.cert" "${LOCAL_CERT_PATH}"
docker cp "${ALICE_CONTAINER_ID}:/cfg/admin.macaroon" "${LOCAL_MACAROON_PATH}"

# Confirm success
if [ -f "${LOCAL_CERT_PATH}" ] && [ -f "${LOCAL_MACAROON_PATH}" ]; then
  echo "Successfully copied tls.cert and admin.macaroon to the local filesystem."
else
  echo "Error: Failed to copy files."
fi
