#!/bin/bash

set -o errexit -o nounset -o pipefail

#instructions provided as a friendly reminder:
#check that your hash matches `sha256sum check.sh`
#execute `./check.sh`
#check for lack of output that says "Bad signature..."
#optionally, check for ok return code (0) with `echo $?`

if [[ $(sha256sum public_key.gpg.asc | grep -Po "^[0-9a-f]+") != "708d2fbff2a07974229961f31a01797e8f55a173f7e450e7977c333fccb3e2a4" ]]; then
	>&2 echo "Bad hash for public_key.gpg.asc"
	exit 1
fi

if [[ -f public_key.gpg ]]; then
	rm public_key.gpg
fi

gpg --output public_key.gpg --dearmor public_key.gpg.asc

export PUBKEY=$(readlink -f public_key.gpg)
export KEY_FULL_ID=$(gpg --no-default-keyring --keyring "$PUBKEY" --list-keys | grep -Po "[0-9A-F]{40}" | tr -d '\n')

function check_sig(){
	set -o errexit -o nounset -o pipefail

	PUBKEY="$PUBKEY"
	KEY_FULL_ID="$KEY_FULL_ID"

	FILE="$0"

	if [[ $(2>/dev/null gpgv --status-fd 1 --keyring "$PUBKEY" "$FILE".sig "$FILE" | grep "^\[GNUPG:\] VALIDSIG $KEY_FULL_ID" | wc -l) != 1 ]]; then
		>&2 echo "Bad signature for following file, removing signature file if it exists"
		#whitelist safe chars to prevent shell injection attacks
		#`head` to get first line only, in case filename has newlines
		echo "$FILE" | head -n1 | >&2 grep -Po "^[a-zA-Z0-9_./-]+"

		if [[ -f "$FILE".sig ]]; then
			rm "$FILE".sig
		fi
	fi
}
export -f check_sig

find . -not "(" -path ./.git -prune ")" -type f -not -name "*.sig" -not -path ./public_key.gpg -print0 | xargs -0 -I %% bash -c "check_sig" %%

rm public_key.gpg
