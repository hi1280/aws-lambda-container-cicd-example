#!/bin/sh

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)
REPOSITORY_URI=${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${REPOSITORY_NAME}
IMAGE_TAG=$(echo "${CODEBUILD_RESOLVED_SOURCE_VERSION}" | cut -c 1-7)

# build
aws ecr get-login-password --region "${AWS_DEFAULT_REGION}" | docker login --username AWS --password-stdin "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com"
docker build -t "${REPOSITORY_URI}:${IMAGE_TAG}" .
docker tag "${REPOSITORY_URI}:${IMAGE_TAG}" "${REPOSITORY_URI}:latest"
docker push "${REPOSITORY_URI}:${IMAGE_TAG}"
docker push "${REPOSITORY_URI}:latest"

# deploy
aws lambda update-function-code --function-name "${REPOSITORY_NAME}" --image-uri "${REPOSITORY_URI}:${IMAGE_TAG}" --publish