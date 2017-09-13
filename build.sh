#!/bin/bash

set -e

docker build -t "inet_phing_test" .

echo ""
echo ""

if [ $? -eq 0 ]; then
    echo -e "\x1b[1;32mBuild Done. To run it: \e[0m"
    echo '  docker run -d --rm --hostname "phing-test-ctn" --name "phing-test-ctn" inet_phing_test'
    echo '  docker exec -i -t "phing-test-ctn" /bin/bash'
    echo "Once Done : "
    echo '  docker stop "phing-test-ctn"'
    echo ""
    echo "Or if you want to directly enter the container, then remove it : "
    echo '  docker run -ti --rm inet_phing_test /bin/bash'
fi
