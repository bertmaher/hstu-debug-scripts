#!/bin/bash

set -xeuo pipefail

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <hash>"
    exit 1
fi

hash=$1
llvm_repo_path="$HSTU_DEBUG_ROOT/llvm-project"
commit_to_cherry_pick="c08c6a71cfc536e22fb7ad733fb8181a9e84e62a"

# Go to the llvm repo directory
cd $llvm_repo_path || { echo "Failed to change directory to $llvm_repo_path"; exit 1; }

# Checkout the hash
git checkout $hash || { echo "Failed to checkout hash $hash"; exit 1; }

if [ -d "build-$hash" ]; then
    echo "build-$hash exists, skipping build"
    exit 0
fi

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

echo "Successfully processed llv mrevision $hash"
