#!/bin/bash

# Environment variables for scheduling (default to 2:00 AM if not set)
CLEANUP_HOUR=${CLEANUP_HOUR:-2}
CLEANUP_MINUTE=${CLEANUP_MINUTE:-0}

# Paths to the mounted crictl binary and containerd socket
CRICTL="/var/lib/rancher/k3s/data/current/bin/crictl"
CONTAINERD_SOCKET="/run/k3s/containerd/containerd.sock"

# Log function for easier debugging and logging
log() {
    echo "$(date): $1"
}

# Check if crictl binary exists
if [ ! -f "$CRICTL" ]; then
    log "crictl binary not found at $CRICTL"
    exit 1
fi

# Check if containerd socket exists
if [ ! -S "$CONTAINERD_SOCKET" ]; then
    log "containerd socket not found at $CONTAINERD_SOCKET"
    exit 1
fi

# Set the runtime endpoint to use the mounted containerd socket
export CONTAINER_RUNTIME_ENDPOINT=unix://$CONTAINERD_SOCKET
export IMAGE_SERVICE_ENDPOINT=unix://$CONTAINERD_SOCKET

# Function to perform image cleanup
perform_cleanup() {
    log "Starting image cleanup"
    $CRICTL rmi --prune

    if [ $? -eq 0 ]; then
        log "Image cleanup successful"
    else
        log "Image cleanup failed"
        exit 1
    fi
}

# Infinite loop to periodically check the time and run cleanup
while true; do
    current_hour=$(date +"%H")
    current_minute=$(date +"%M")

    if [ "$current_hour" -eq "$CLEANUP_HOUR" ] && [ "$current_minute" -eq "$CLEANUP_MINUTE" ]; then
        perform_cleanup
        # Sleep for 23 hours to avoid rerunning on the same day and allow for slight delays
        sleep 23h
    else
        # Sleep for 1 minute and check again
        sleep 1m
    fi
done