I think there's still a performance regression in HSTU ragged attention between
Triton 3.1 and Triton 3.2.  To prove this I had to re-linearize history by
applying a few cherry-picks/backports to the 3.1 merge-base.  In any event, you
can repro what I'm seeing as follows:

```
source activate.sh
./setup.sh
./repro.sh
```

This will output gobs of debugging/build/etc output, but also a data table for the "good" and "bad" Triton revisions.

Example good result:
```
                               x_val    hstu_triton_ragged_attention-latency
------------------------------------  --------------------------------------
(256, 4, 4096, 2048, 0.95, 20, True)                                 158.417
```

Example bad result:
```
                               x_val    hstu_triton_ragged_attention-latency
------------------------------------  --------------------------------------
(256, 4, 4096, 2048, 0.95, 20, True)                                 171.121
```

The last good revision is 579d782d0 (`hstu-debug-good`)

The first bad revision is 707bec095, which corresponds to
https://github.com/triton-lang/triton/pull/4507 ([BACKEND] Fix linear layout's
distributed to distributed layout conversion using shared memory).

Two additional commits (`hstu-debug-bad`) reduce the regression somewhat by
introducing a knob and turning if off, but there is clearly still a regression.
