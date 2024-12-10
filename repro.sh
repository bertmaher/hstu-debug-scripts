#!/bin/bash

set -xeuo pipefail

cd "$HSTU_DEBUG_ROOT"

(cd triton && git checkout hstu-debug-good)
./test-triton.sh  # About 171 ms

(cd triton && git checkout hstu-debug-bad)
./test-triton.sh  # About 157 ms
