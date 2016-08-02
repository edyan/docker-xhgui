#!/bin/bash
docker rmi inetprocesstestxhgui
docker build -t "inetprocesstestxhgui" .
echo ""
echo ""
if [ $? -eq 0 ]; then
    # docker run -d --hostname xhgui --name xhgui inetprocesstestxhgui
    echo -e "\x1b[1;32mBuild Done\e[0m"
fi
