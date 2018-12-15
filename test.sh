#!/bin/bash

set -e

if [ -z "php${1}" -o ! -d "php${1}" ]; then
    echo "You must define a valid image version to build as parameter"
    exit 1
fi

DIRECTORY=$(cd `dirname $0` && pwd)
VERSION=php${1}
GREEN='\033[0;32m'
NC='\033[0m' # No Color

cd ${DIRECTORY}/${VERSION}
docker build -t "edyan_xhgui${VERSION}_test" .


echo ""
echo -e "${GREEN}Testing version ${VERSION} ${NC}"
cd ${DIRECTORY}/${VERSION}/tests
dgoss run "edyan_xhgui${VERSION}_test"