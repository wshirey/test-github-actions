FROM golang:1.13

LABEL "com.github.actions.name"="go benchcmp"
LABEL "com.github.actions.description"="Compare Go benchmarks"
LABEL "com.github.actions.icon"="terminal"
LABEL "com.github.actions.color"="blue"

LABEL "repository"="https://github.com/wshirey/test-github-actions"
LABEL "repository"="https://github.com/wshirey/test-github-actions"
LABEL "repository"="Wally Shirey <waltshirey@gmail.com>"

RUN apt-get update && \
    apt-get install -y jq && \
    go get -u golang.org/x/tools/cmd/benchcmp

ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
