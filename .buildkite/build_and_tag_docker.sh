#!/bin/bash
set -eu
docker build  -t ${PIPELINE_DOCKER_REGISTRY_URL}:${PIPELINE_IMAGE_TAG} .
docker run --rm ${PIPELINE_DOCKER_REGISTRY_URL}:${PIPELINE_IMAGE_TAG} $PIPELINE_TEST_DOCKER_IMAGE_COMMAND
docker login  -u $DOCKER_USER --password-stdin <<< "$DOCKER_PASS"
