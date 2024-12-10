#!/bin/bash

set -xeuo pipefail

cd "$HSTU_DEBUG_ROOT/triton/python"
"$HSTU_DEBUG_ROOT/build-triton.sh"

cd "$HSTU_DEBUG_ROOT/tritonbench"
"$HSTU_DEBUG_ROOT/denoise-h100.sh" python run.py --op ragged_attention --mode bwd --max-seq-len-log2 13 --input-id 4
