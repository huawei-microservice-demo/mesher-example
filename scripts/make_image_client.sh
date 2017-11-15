#!/usr/bin/env bash
set -e
set -x

check_GOPATH(){
  if [ -z $GOPATH ]; then
    echo "ERROR: GOPATH is not set"
    exit 1
  fi
}

service="client"
appname="serviceclient"
packagename=$appname.tar.gz
SCRIPT_PATH=$(cd $(dirname $0);pwd)/../client
BUILD_PATH=$(cd $(dirname $SCRIPT_PATH);pwd)/$service

cd $BUILD_PATH
check_GOPATH
go build -o clientapp

if [ -d $appname ]; then
  rm -rf $appname
fi

mkdir $appname
cp clientapp $appname
tar -czvf $packagename $appname
rm -rf $appname
rm -rf clientapp
#mv $packagename $SCRIPT_PATH
cd $SCRIPT_PATH
docker build -t mesher-client:latest .
rm -rf $packagename

