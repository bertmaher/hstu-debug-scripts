#!/bin/bash

# Usage: ./process_revisions.sh <branch_a> <branch_b>
# Example: ./process_revisions.sh a b

# Check if the correct number of arguments is provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <branch_a> <branch_b>"
    exit 1
fi

branch_a=$1
branch_b=$2
triton_repo_path="/data/users/bertrand/hstu-perf/triton-fbsource"
llvm_repo_path="/data/users/bertrand/hstu-perf/llvm-project-fbsource"
commit_to_cherry_pick="c08c6a71cfc536e22fb7ad733fb8181a9e84e62a"

cd $triton_repo_path

# Get the list of revisions that change cmake/llvm-hash.txt
initial=$(git rev-parse $branch_a)
revisions=$(git log --pretty=format:"%H" --reverse $branch_a..$branch_b -- cmake/llvm-hash.txt)
revisions="$initial $revisions"

# Iterate over each revision
for revision in $revisions; do
    echo "Processing revision $revision"

    cd $triton_repo_path

    # Get the contents of cmake/llvm-hash.txt for the current revision
    hash=$(git show $revision:cmake/llvm-hash.txt)

    if [ -z "$hash" ]; then
        echo "Failed to retrieve hash from cmake/llvm-hash.txt for revision $revision"
        exit 1
    fi

    echo "Hash from cmake/llvm-hash.txt: $hash"

    # Go to the llvm repo directory
    cd $llvm_repo_path || { echo "Failed to change directory to $llvm_repo_path"; exit 1; }

    if [ -d "build-$hash" ]; then
        echo "build-$hash exists, skipping build"
        continue
    fi

    # Checkout the hash
    git checkout $hash || { echo "Failed to checkout hash $hash"; exit 1; }

    # Cherry-pick the specified commit
    if [ $(git merge-base "$commit_to_cherry_pick" "$hash") != "$commit_to_cherry_pick" ]; then
        git cherry-pick $commit_to_cherry_pick
        if [ $? -ne 0 ]; then
            echo "Cherry-pick failed for commit $commit_to_cherry_pick. Aborting."
            git cherry-pick --abort
            exit 1
        fi
    fi

    # Build LLVM
    build_dir="build-$hash"
    mkdir -p $build_dir
    cd $build_dir || { echo "Failed to change directory to build"; exit 1; }
    cmake -G Ninja -DCMAKE_BUILD_TYPE=Release -DLLVM_ENABLE_ASSERTIONS=ON ../llvm -DLLVM_ENABLE_PROJECTS="mlir;llvm" -DLLVM_TARGETS_TO_BUILD="host;NVPTX;AMDGPU" -DLLVM_BUILD_TOOLS=OFF
    if [ $? -ne 0 ]; then
        echo "CMake configuration failed."
        exit 1
    fi

    nice ninja
    if [ $? -ne 0 ]; then
        echo "Build failed."
        exit 1
    fi

    echo "Successfully processed revision $revision with hash $hash"
done

echo "All revisions processed successfully."
