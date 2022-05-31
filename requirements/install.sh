#!/bin/bash
set -e
DIR=$(dirname $0)

for i in $(find $DIR -maxdepth 1 -mindepth 1 -type d); do
  pushd $i && helmfile sync --wait && popd
done
