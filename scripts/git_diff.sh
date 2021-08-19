#!/bin/sh

set -eux

set +e
git diff --quiet --exit-code "${DIRECTORY}"
exit_code=$?
unchecked_files=$(git status -u "${DIRECTORY}" -s)
set -e

if [ $exit_code -eq 0 ] && [ "$unchecked_files" = "" ]; then 
    echo "All generated manifests checked into '${DIRECTORY}' directory."; 
else 
    echo "Changes NOT checked in!!!"
    # print out all files that have diffs not checked in
    git status --porcelain "${DIRECTORY}"
    exit 1
fi