#!/bin/bash
set -e

echo "Building Go Lambda..."
cd terraform/modules/url-shortener
GOOS=linux GOARCH=amd64 go build -o bootstrap main.go

cd ../../..

echo "Terraform dev init and apply..."
cd terraform/environments/dev/
terraform init
terraform apply
