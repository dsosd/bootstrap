#!/bin/bash

set -o errexit -o nounset -o pipefail

GPG_DIR="$1"
COMMAND='set -o errexit -o nounset -o pipefail

if ! [[ -f "$0".sig ]]; then
	gpg --homedir '"$GPG_DIR"' --output "$0".sig --detach --sign "$0"
fi'

find . -not "(" -path ./.git -prune ")" -type f -not -name "*.sig" -not -path ./public_key.gpg -print0 | xargs -0 -I %% bash -c "$COMMAND" %%
