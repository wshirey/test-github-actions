#!/bin/sh
set -e

run_go_benchmark() {
    echo "checking out $GIT_COMMIT"
    GIT_COMMIT=$1
    BENCHMARK_FILE=$HOME/$GIT_COMMIT.txt
    git clean -ffdx && git reset --hard HEAD
    git checkout $GIT_COMMIT
    echo "running project benchmarks"
    go test -run=NONE -benchmem=true -bench=. ./... > $BENCHMARK_FILE
    echo "benchmark results:"
    cat $BENCHMARK_FILE
    return $BENCHMARK_FILE
}

main() {
    OLD_BENCHMARK_FILE=$(run_go_benchmark $GITHUB_BASE_REF)
    NEW_BENCHMARK_FILE=$(run_go_benchmark $GITHUB_HEAD_REF)
    BENCHCMP_RESULTS=$(benchcmp $OLD_BENCHMARK_FILE $NEW_BENCHMARK_FILE)
    echo "benchcmp results:"
    echo $BENCHCMP_RESULTS
}

main "$@"