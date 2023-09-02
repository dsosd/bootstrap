#!/bin/bash

set -o errexit -o nounset -o pipefail

find . -not "(" -path ./.git -prune ")" -type f -name "*.sig" -print0 | xargs -0 -I %% rm %%
