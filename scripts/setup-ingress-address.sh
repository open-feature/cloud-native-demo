#!/bin/bash

# Set the namespace and Ingress name to watch
NAMESPACE="open-feature-demo"
INGRESS_NAME="playground-ingress"

# Set the Secret name to create
SECRET_NAME="ingress-address"

# Loop until the Ingress has an address
while true; do
    # Get the Ingress resource
    ADDRESS=$(kubectl get ingress -n ${NAMESPACE} ${INGRESS_NAME} -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

    # Check if the Ingress has an address
    if [ -n "${ADDRESS}" ]; then
        # Check if the Secret already exists and delete it if necessary
        if kubectl get secret ${SECRET_NAME} -n ${NAMESPACE} >/dev/null 2>&1; then
            echo "Secret ${SECRET_NAME} already exists. Deleting..."
            kubectl delete secret ${SECRET_NAME} -n ${NAMESPACE}
        fi

        # Create the Secret containing the address
        kubectl create secret generic ${SECRET_NAME} --from-literal=address=${ADDRESS} -n ${NAMESPACE}

        # Exit the loop
        break
    fi

    # Wait for 5 seconds before checking again
    sleep 5
done