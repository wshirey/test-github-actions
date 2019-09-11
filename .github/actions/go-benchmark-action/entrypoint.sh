#!/bin/sh
set -e

add_issue_comment() {
   COMMENT="#### \`benchcmp \`
    \`\`\`
    $1
    \`\`\`
    "
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
    run_go_benchmark $GITHUB_BASE_REF $HOME/$GITHUB_BASE_REF.txt
    run_go_benchmark $GITHUB_HEAD_REF $HOME/$GITHUB_HEAD_REF.txt
    echo "running benchcmp $HOME/$GITHUB_BASE_REF.txt $HOME/$GITHUB_HEAD_REF.txt"
    BENCHCMP_RESULTS=$(benchcmp $HOME/$GITHUB_BASE_REF.txt $HOME/$GITHUB_HEAD_REF.txt)
    add_issue_comment $BENCHCMP_RESULTS
}

main "$@"
echo $?