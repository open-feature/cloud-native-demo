#!/bin/bash

INGRESS_IP=$(kubectl get ingress -n open-feature-demo playground-ingress -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

echo "Playground application: http://${INGRESS_IP}"
echo "Jaeger UI:              http://${INGRESS_IP}/tracing"