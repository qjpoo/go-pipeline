#!/bin/bash

set -x
go env -w  GOPROXY=https://goproxy.cn,direct
go env -w  GO111MODULE="on"
go mod init
go get -d -v golang.org/x/net/html
go get -u github.com/jstemmer/go-junit-report
go mod vendor
ls -al
go test -v 2>&1 > tmp
status=$?
$GOPATH/bin/go-junit-report < tmp > test_output.xml &&  touch *.xml

exit ${status}
