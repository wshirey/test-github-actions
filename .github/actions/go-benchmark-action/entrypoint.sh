#!/bin/sh
set -e

add_issue_comment() {
   COMMENT="#### \`benchcmp \`
\`\`\`
$1
\`\`\`"
    PAYLOAD=$(echo '{}' | jq --arg body "$COMMENT" '.body = $body')
    COMMENTS_URL=$(cat /github/workflow/event.json | jq -r .pull_request.comments_url)

    if [ "COMMENTS_URL" != null ]; then
        curl -s -S -H "Authorization: token $GITHUB_TOKEN" --header "Content-Type: application/json" --data "$PAYLOAD" "$COMMENTS_URL" > /dev/null
    fi
}

run_go_benchmark() {
    GIT_COMMIT=$1
    BENCHMARK_FILE=$2
    git clean -ffdx && git reset --hard HEAD
    git checkout $GIT_COMMIT
    go test -run=NONE -benchmem=true -bench=. ./... > $BENCHMARK_FILE
}

main() {
    cd $GITHUB_WORKSPACE

    OLD_BENCHMARK_FILE=$HOME/$GITHUB_BASE_REF.txt
    mkdir -p "$(dirname "$OLD_BENCHMARK_FILE")" && touch "$OLD_BENCHMARK_FILE"
    run_go_benchmark $GITHUB_BASE_REF $OLD_BENCHMARK_FILE

    NEW_BENCHMARK_FILE=$HOME/$GITHUB_HEAD_REF.txt
    mkdir -p "$(dirname "$NEW_BENCHMARK_FILE")" && touch "$NEW_BENCHMARK_FILE"
    run_go_benchmark $GITHUB_HEAD_REF $NEW_BENCHMARK_FILE

    echo "running benchcmp $OLD_BENCHMARK_FILE $NEW_BENCHMARK_FILE"
    BENCHCMP_RESULTS=$(benchcmp "$OLD_BENCHMARK_FILE" "$NEW_BENCHMARK_FILE")
    echo "adding comment with benchmp results"
    add_issue_comment "$BENCHCMP_RESULTS"
}

main "$@"
echo $?