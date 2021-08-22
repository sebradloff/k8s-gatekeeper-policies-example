#!/bin/sh

## This script exists to copy all generated and hand written contraints, templates, and sync files
## to the manifests directory. There are situations where we will not want to generate a constraint
## with the konstraint cli and manually create them. Example in this issue for excludingNamespaces: 
## https://github.com/plexsystems/konstraint/issues/106
set -eux

MANIFESTS_DIR="manifests"
CONSTRAINTS_DIR="${MANIFESTS_DIR}/constraint"
TEMPLATE_DIR="${MANIFESTS_DIR}/template"

rm -rf "${MANIFESTS_DIR}"
mkdir -p "${CONSTRAINTS_DIR}"
mkdir -p "${TEMPLATE_DIR}"

for file_path in $(find * -type f -iname "constraint.yaml" -o); do
  new_file_name=$(echo "${file_path}" | sed -e 's|/|\-|g' -e 's/policies-//gI')
  cp "${file_path}" "${CONSTRAINTS_DIR}/${new_file_name}"
done

for file_path in $(find * -type f -iname "template.yaml" -o); do
  new_file_name=$(echo "${file_path}" | sed -e 's|/|\-|g' -e 's/policies-//gI')
  cp "${file_path}" "${TEMPLATE_DIR}/${new_file_name}"
done

if [ $(find policies/ -type f -iname "sync.yaml") ]; then
  cp $(find policies/ -type f -iname "sync.yaml")  "${MANIFESTS_DIR}/sync.yaml"
fi