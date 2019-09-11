FROM golang:1.13

RUN apt-get update && \
    apt-get install -y jq && \
    go get -u golang.org/x/tools/cmd/benchcmp

ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
