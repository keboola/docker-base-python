#!/bin/bash

docker login -e="." -u="$QUAY_USERNAME" -p="$QUAY_PASSWORD" quay.io
docker tag keboola/base-python quay.io/keboola/base-python:$TRAVIS_TAG
docker tag keboola/base-python quay.io/keboola/base-python:latest
docker images
docker push quay.io/keboola/base-python:$TRAVIS_TAG
docker push quay.io/keboola/base-python:latest
