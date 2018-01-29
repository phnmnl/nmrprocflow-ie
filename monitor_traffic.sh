#!/bin/bash
while true; do
    sleep 600
    if [ `netstat -t | grep -v CLOSE_WAIT | grep -E ':(80|http)' | wc -l` -lt 3 ]
    then
        pkill apache2
    fi
done
