#!/bin/bash

if [ $# -ne 2]; then
    echo "Usage: $0 branch_a branch_b"
    exit 1
fi

branch_a=$1
branch_b=$2

commits=$(git rev-list --reverse $branch_a..$branch_b)
for commit in $commits; do
    echo "Attempting to cherry-pick $commit"
    git cherry-pick $commit
    if [ $? -ne 0 ]; then
        echo "Cherry-pick failed for commit $commit. Aborting."
        git cherry-pick --abort
        exit 1
    fi
done
echo "Success!"
