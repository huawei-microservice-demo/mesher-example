#!/bin/sh
set -e
until [ $(curl -I -s -o /dev/null -w "%{http_code}" "$CSE_REGISTRY_ADDR"/health -X GET -k) -eq "200" ]; do
  >&2 echo "Service Center is unavailable -sleeping"
  sleep 1
done

>&2 echo "Service Center is UP - running mesher"
