#!/bin/bash

set -e

if [ -z "$1" -o ! -d "$1" ]; then
    echo "You must define a valid PHP version to build as parameter (5.6 or 7.2)"
    exit 1
fi

VERSION=$1
GREEN='\033[0;32m'
NC='\033[0m' # No Color

cd $1
docker build -t "edyan_xhgui_${VERSION}_test" .
echo ""
echo ""
if [ $? -eq 0 ]; then
    echo -e "${GREEN}Build Done${NC}."
    echo ""
    echo "Run :"
    echo "  docker run --rm --hostname xhgui_${VERSION}-test-ctn --name xhgui_${VERSION}-test-ctn edyan_xhgui_${VERSION}_test"
    echo "  docker exec -i -t xhgui_${VERSION}-test-ctn /bin/bash"
    echo "Once Done : "
    echo "  docker stop xhgui_${VERSION}-test-ctn"
    echo ""
    echo "Or if you want to directly enter the container, then remove it : "
    echo "  docker run -ti --rm edyan_xhgui_${VERSION}_test /bin/bash"
fi
