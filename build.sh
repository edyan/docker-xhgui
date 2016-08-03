#!/bin/bash
docker build -t "inet_php_xhgui" .
echo ""
echo ""
if [ $? -eq 0 ]; then
    # docker run -d --hostname xhgui --name xhgui inet_php_xhgui
    echo -e "\x1b[1;32mBuild Done\e[0m"
fi
