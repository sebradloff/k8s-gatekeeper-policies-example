#!/bin/sh

## This script exists to copy all generated and hand written contraints, templates, and sync files
## to the manifests directory
set -eux

rm -rf manifests
mkdir -p manifests

for file_path in $(find * -type f -iname "constraint.yaml" -o -iname "template.yaml"); do
  new_file_name=$(echo "${file_path}" | sed -e 's|/|\-|g' -e 's/policies-//gI')
  cp "${file_path}" "./manifests/${new_file_name}"
done

if [ $(find policies/ -type f -iname "sync.yaml") ]; then
  cp $(find policies/ -type f -iname "sync.yaml")  "./manifests/sync.yaml"
fi