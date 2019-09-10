#!/bin/sh
set -e

echo "Changing directory to $GO_BENCHMARK_DIR"
cd "${GO_BENCHMARK_DIR:-.}"
ls

set +e
OUTPUT="$(benchcmp old.txt new.txt)"
SUCCESS=$?
echo $SUCCESS
set -e

# Post results back as comment.
COMMENT="#### \`benchcmp\`
\`\`\`
$OUTPUT
\`\`\`
"
PAYLOAD=$(echo '{}' | jq --arg body "$COMMENT" '.body = $body')
COMMENTS_URL=$(cat /github/workflow/event.json | jq -r .pull_request.comments_url)

if [ "COMMENTS_URL" != null ]; then
  curl -s -S -H "Authorization: token $GITHUB_TOKEN" --header "Content-Type: application/json" --data "$PAYLOAD" "$COMMENTS_URL" > /dev/null
fi

exit $SUCCESS