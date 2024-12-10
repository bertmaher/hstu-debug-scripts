#!/bin/bash

set -xeuo pipefail

git clone https://github.com/bertmaher/triton.git
(cd triton && git checkout hstu-debug)

git clone https://github.com/llvm/llvm-project.git

git clone https://github.com/pytorch-labs/tritonbench.git

(cd tritonbench \
     && git checkout f92c38ecdaf1d2c93499f2e287dc8ca41c9c294b \
     && git submodule update --init --recursive)
patch -p1 -d tritonbench/submodules/generative-recommenders < hstu.diff
