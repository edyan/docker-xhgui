#!/bin/bash

set -e

if [ -z "$1" -o ! -d "php$1" ]; then
    echo "You must define a valid PHP version to build as parameter (5.6 or 7.2)"
    exit 1
fi

VERSION=$1
GREEN='\033[0;32m'
NC='\033[0m' # No Color

cd php$1
docker build -t "edyan_phing_php${VERSION}_test" .
echo ""
echo ""
if [ $? -eq 0 ]; then
    echo -e "${GREEN}Build Done${NC}."
    echo ""
    echo "Run :"
    echo "  docker run --rm --hostname phing_php${VERSION}-test-ctn --name phing_php${VERSION}-test-ctn edyan_phing_php${VERSION}_test"
    echo "  docker exec -i -t phing_php${VERSION}-test-ctn /bin/bash"
    echo "Once Done : "
    echo "  docker stop phing_php${VERSION}-test-ctn"
    echo ""
    echo "Or if you want to directly enter the container, then remove it : "
    echo "  docker run -ti --rm edyan_phing_php${VERSION}_test /bin/bash"
fi
