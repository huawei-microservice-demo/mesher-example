#!/bin/sh
set -e
set -x

name="serviceserver"
cd /tmp/service-server/$name
./serverapp
