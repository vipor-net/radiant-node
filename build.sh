#!/bin/bash
export DOCKER_CLI_EXPERIMENTAL=enabled
docker build -t iotapi322/radiant:v1.2.0 -f Dockerfile .
