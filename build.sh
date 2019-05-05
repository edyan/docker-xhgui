#!/bin/bash

set -e

if [ -z "$1" -o ! -d "$1" ]; then
    echo "You must define a valid PHP / Xhgui version to build as parameter"
    exit 1
fi

VERSION=$1
GREEN='\033[0;32m'
NC='\033[0m' # No Color
TAG=edyan/xhgui:${VERSION}

cd $1

echo "Building ${TAG}"
docker build -t ${TAG} .
if [[ "$VERSION" == "php7.2" ]]; then
  echo ""
  echo "${TAG} will also be tagged 'latest'"
  docker tag ${TAG} edyan/xhgui:latest
fi

echo ""
echo ""
if [ $? -eq 0 ]; then
    echo -e "${GREEN}Build Done${NC}."
    echo ""
    echo "Run:"
    echo "  docker container run -d --rm --name xhgui-test-ctn -p 8080:80 ${TAG}"
    echo "  docker container exec -ti xhgui-test-ctn /bin/bash"
    echo "Then create a PHP script, etc."
    echo "Once Done : "
    echo "  docker container stop xhgui-test-ctn"
    echo ""
    echo "Or if you want to directly enter the container, then remove it : "
    echo "  docker run -ti --rm ${TAG} /bin/bash"
    echo "To push that version (and other of the same repo):"
    echo "  docker push edyan/xhgui"
fi
