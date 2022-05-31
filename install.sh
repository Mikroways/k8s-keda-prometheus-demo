#!/bin/bash

set -e

kind create cluster --config kind-config.yaml
./requirements/install.sh
kubectl apply -k application/
