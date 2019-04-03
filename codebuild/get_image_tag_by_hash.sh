#!/bin/sh

aws ecr list-images --repository-name "${1}" --query \
"imageIds[?imageDigest=='${CODEBUILD_RESOLVED_SOURCE_VERSION}'].imageTag" \
--output text

