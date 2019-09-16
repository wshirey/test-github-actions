#!/bin/sh
set -e

ACTION_WATERMARK="go-benchmark-action_b7eb8b69-badf-43e9-b776-24df51f5b5d3"

add_issue_comment() {
    COMMENTS_URL=$(cat /github/workflow/event.json | jq -r .pull_request.comments_url)
    if [ -z "$COMMENTS_URL" ]; then
        echo "no ''.pull_request.comments_url' property present in github event"
        return
    fi

    UPDATE_COMMENT_URL=$(curl -s -S -H "Authorization: token $GITHUB_TOKEN" --header "Content-Type: application/json" "$COMMENTS_URL" | jq "map(select(.body | test(\""$ACTION_WATERMARK"\"))) | .[0].url" -r)
    echo "$UPDATE_COMMENT_URL"
    if [ "$UPDATE_COMMENT_URL" != "null" ]; then
        COMMENTS_URL="$UPDATE_COMMENT_URL"
        METHOD="PATCH"
        echo "updating comment with url $COMMENTS_URL"
    else
        METHOD="POST"
        echo "creating comment with url $COMMENTS_URL"
    fi


    COMMENT="
<!--$ACTION_WATERMARK-->
#### \`benchcmp \`
\`\`\`
$1
\`\`\`"
    PAYLOAD=$(echo '{}' | jq --arg body "$COMMENT" '.body = $body')
    echo "curl -s -S -H "Authorization: token "$GITHUB_TOKEN"" --header "Content-Type: application/json" --data "$PAYLOAD" -X "$METHOD" "$COMMENTS_URL""
    curl -s -S -H "Authorization: token "$GITHUB_TOKEN"" --header "Content-Type: application/json" --data "$PAYLOAD" -X "$METHOD" "$COMMENTS_URL" > /dev/null
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