#!/bin/sh

# Check if exactly two arguments are provided: <namespace> and <output_directory>
if [ $# -ne 2 ]; then
    echo "Usage: $0 <namespace> <output_directory>" >&2
    exit 1
fi

NAMESPACE="$1"
OUTPUT_DIR="$2"

# Create the output directory if it does not exist
mkdir -p "$OUTPUT_DIR"
if [ ! $? ]; then
    echo "Failed to create output directory: $OUTPUT_DIR" >&2
    exit 1
fi

# Fetch all pod names in the specified namespace using kubectl
PODS=$(kubectl get pods -n "$NAMESPACE" -o jsonpath='{.items[*].metadata.name}' 2>/dev/null)
if [ ! $? ]; then
    echo "Error retrieving pods from namespace: $NAMESPACE" >&2
    exit 1
fi

# Exit if no pods found in the namespace
if [ -z "$PODS" ]; then
    echo "No pods found in namespace: $NAMESPACE"
    exit 0
fi

# Process each pod to collect logs from all containers (regular and init)
for POD in $PODS; do
    echo "Processing pod: $POD"

    # Fetch init container names for the current pod first
    INIT_CONTAINERS=$(kubectl get pod "$POD" -n "$NAMESPACE" -o jsonpath='{.spec.initContainers[*].name}' 2>/dev/null)
    if [ ! $? ]; then
        echo "Failed to get init containers for pod: $POD" >&2
        continue
    fi

    # Fetch regular container names for the current pod
    CONTAINERS=$(kubectl get pod "$POD" -n "$NAMESPACE" -o jsonpath='{.spec.containers[*].name}' 2>/dev/null)
    if [ ! $? ]; then
        echo "Failed to get containers for pod: $POD" >&2
        continue
    fi

    # Combine init container and regular names into a single list for logs
    ALL_CONTAINERS="$INIT_CONTAINERS $CONTAINERS"

    # Skip if no containers are found for the pod
    if [ -z "$ALL_CONTAINERS" ]; then
        echo "No containers or init containers found for pod: $POD"
        continue
    fi

    # Save logs for each init container in the list
    for CONTAINER in $ALL_CONTAINERS; do
        echo "Fetching logs for container: $CONTAINER"
        kubectl logs "$POD" -n "$NAMESPACE" -c "$CONTAINER" >> "${OUTPUT_DIR}/${POD}.log"
        if [ ! $? ]; then
            echo "Failed to retrieve logs for pod $POD, container $CONTAINER" >&2
        fi
    done
done


echo "Logs saved to directory: $OUTPUT_DIR"

