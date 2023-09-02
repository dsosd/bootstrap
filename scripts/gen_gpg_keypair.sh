#!/bin/bash

set -o errexit -o nounset -o pipefail

function gen_key(){
	rm -r ../bootstrap_gpg/*
	mkdir private-keys-v1.d

	#MAGIC 2106-02-07 06:28:14 is the latest time gpg will accept (this is max unix time, in seconds represented as 32 bit unsigned, minus 1 second)
	2>&1 gpg --homedir . --batch --faked-system-time 0 --passphrase "" --quick-generate-key "Automated bootstrap signing key <admin@null.dev>" ed25519 sign 21060207T062814 | tail -n1 | grep -Po "/[0-9A-F]{40}" | head -c5 | tail -c+2
}

mkdir bootstrap_gpg
chmod 700 bootstrap_gpg
cd bootstrap_gpg

ANS=""

#MAGIC 2f00 is arbitrary
while [[ "$ANS" != "2F00" ]]; do
	ANS=$(gen_key)
	echo -n "+"
done

rm -r openpgp-revocs.d

gpg --homedir . --armor --export-secret-keys $(gpg --homedir . --list-public-keys | grep -Po "[0-9A-F]{40}" | tr -d '\n') >secret_key.gpg.asc
gpg --homedir . --armor --export $(gpg --homedir . --list-public-keys | grep -Po "[0-9A-F]{40}" | tr -d '\n') >public_key.gpg.asc
