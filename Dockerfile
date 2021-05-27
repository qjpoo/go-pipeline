FROM golang
WORKDIR /go/src/gowebdemo/

ENV GOPROXY=https://goproxy.cn,direct
ENV GO111MODULE="on"
RUN go mod init && \
    go get -d -v golang.org/x/net/html && \
    go mod vendor
COPY app.go .
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o gowebdemo .

FROM alpine:latest
RUN apk --no-cache add ca-certificates
WORKDIR /root/
COPY --from=0 /go/src/gowebdemo .
EXPOSE 8088
CMD ["./gowebdemo"]
