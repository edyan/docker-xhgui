#!/bin/bash

set -e

if [ -z "${1}" -o ! -d "${1}" ]; then
    echo "You must define a valid image version to build as parameter"
    exit 1
fi

DIRECTORY=$(cd `dirname $0` && pwd)
VERSION=${1}
GREEN='\033[0;32m'
NC='\033[0m' # No Color

cd ${DIRECTORY}/${VERSION}
docker build -t "edyan_xhgui_${VERSION}_test" .


echo ""
echo -e "${GREEN}Testing version ${VERSION} ${NC}"
cd ${DIRECTORY}/${VERSION}/tests
export GOSS_FILES_STRATEGY=cp
dgoss run "edyan_xhgui_${VERSION}_test"
