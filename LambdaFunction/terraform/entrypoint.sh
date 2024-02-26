#!/bin/sh

echo "Waiting for LocalStack to be ready..."
while ! nc -z localstack 4566; do
  sleep 1
done

echo "LocalStack is ready."

terraform init -lock=false
terraform apply -lock=false -auto-approve