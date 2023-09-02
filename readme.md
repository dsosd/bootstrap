## `dsosd/bootstrap`

`bootstrap` is a collection of signed data files that assist in bootstrapping a bare Linux system that is connected to the internet. This centralizes info that *needs* to be verified on first use, such as ssh server public key fingerprints, package manager repository gpg keys, and self-signed ssl root certificates.

A user should have a (known-good) sha256 hash of `check.sh`, so that they can verify its integrity via `sha256sum check.sh`, before executing it. Executing `check.sh` in turn verifies the integrity of the files in the rest of the repo.

### Install via git
Clone the repository via `git clone --depth 1 {repo url}`. The official repo urls are:
`https://git.xor.fyi/dsosd/bootstrap`
`https://github.com/dsosd/bootstrap`

### Dependencies
The scripts assume that the following executables are available in `$PATH`.

```
bash
chmod
echo
find
gpg
gpgv
grep (with Perl option)
head
mkdir
readlink
rm
sha256sum
tail
tr
wc
xargs
```

### Notes
#### Mutability
Due to a lack of a manifest file, an attacker could rename/remove files from the repo or replace them with older/newer versions, without `check.sh` noticing the manipulation. This is intentional as it may be desirable to have files from different versions of the repo "at once".

To ensure that no files have been renamed or removed, a manifest file should be generated via `find . -not "(" -path ./.git -prune ")" -type f -not -name "*.sig" -not -path ./manifest -print0 | sort -z | xargs -0 -I %% sha256sum %% >manifest`. By placing the manifest in the repo, it would be subject to the same verification performed by `check.sh` on other files. The user could verify the manifest's contents by saving a copy of it, generating a new manifest, and diffing the two.

To prevent version downgrades, a different gpg key should be used for each version. `scripts/gen_gpg_keypair.sh` is somewhat computationally expensive because it currently generates a vanity keypair that has `2f 00` as the first two bytes of the full key id. This is completely unnecessary, so if a new key is being made for each version, the script should be patched to remove the while loop.

#### Gpg key
The gpg key hardcoded in the repo (in `check.sh` and `public_key.gpg.asc`) is meant for my personal use. You should generate your own keypair (see `scripts/gen_gpg_keypair.sh` as a reference) and replace the hardcoded parts as appropriate.

### License
This project is under the MIT license. See `license` for the full license.
