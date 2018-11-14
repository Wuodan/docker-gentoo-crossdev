#!/bin/bash

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
REPO=wuodan
IMAGE=$(basename $DIR)
TAG=latest
FULL_TAG=${REPO}/${IMAGE}:${TAG}
DATETIME=$(date '+%Y%m%d%H%M%S')

echo "Refreshing base images"
for base in $(sed -En 's#^[[:space:]]*FROM[[:space:]]+([^ \t]+)#\1#p' ${DIR}/Dockerfile | sed -E 's#\t# #g' | cut -d ' ' -f 1); do
	docker pull ${base}
done

mkdir -p ${DIR}/log
echo "Build image, write log to : ${DIR}/log/docker-build.${DATETIME}.log"
docker build --tag ${FULL_TAG} $DIR 2>&1 | tee ${DIR}/log/docker-build.${DATETIME}.log

echo "Push image ..."
docker push ${FULL_TAG}

echo "Done"
