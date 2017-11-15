#!/usr/bin/env bash
set -e
set -x

check_GOPATH(){
  if [ -z $GOPATH ]; then
    echo "ERROR: GOPATH is not set"
    exit 1
  fi
}

service="server"
appname="serviceserver"
packagename=$appname.tar.gz
SCRIPT_PATH=$(cd $(dirname $0);pwd)/../server
BUILD_PATH=$(cd $(dirname $SCRIPT_PATH);pwd)/$service

cd $BUILD_PATH
check_GOPATH
go build -o serverapp

if [ -d $appname ]; then
  rm -rf $appname
fi

mkdir $appname
cp serverapp $appname
tar -czvf $packagename $appname
rm -rf $appname
rm -rf serverapp
#mv $packagename $SCRIPT_PATH
cd $SCRIPT_PATH
docker build -t mesher-server:latest .
rm -rf $packagename
