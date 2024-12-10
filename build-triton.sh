#!/bin/bash

set -xeuo pipefail

triton_dir="$HSTU_DEBUG_ROOT/triton/python"
cd "$triton_dir" || { echo "Can't cd to $triton_dir"; exit 1; }

hash=$(cat ../cmake/llvm-hash.txt)

llvm_build="$HSTU_DEBUG_ROOT/llvm-project/build-$hash"
echo "LLVM Build directory: $llvm_build"
"$HSTU_DEBUG_ROOT/build-llvm.sh" $hash

export LLVM_BUILD_DIR="$llvm_build"
LLVM_INCLUDE_DIRS=$LLVM_BUILD_DIR/include     LLVM_LIBRARY_DIR=$LLVM_BUILD_DIR/lib     LLVM_SYSPATH=$LLVM_BUILD_DIR     python setup.py develop
