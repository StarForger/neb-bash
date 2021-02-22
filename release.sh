#!/usr/bin/env bash

mkdir -p build

rm -f build/*.tgz

7z a -ttar -so -an ./scripts/* | 7z a -si build/neb-bash.tgz