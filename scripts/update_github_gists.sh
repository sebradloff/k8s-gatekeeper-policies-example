#!/bin/sh

set -eu
## This script exists to sync all github gists used in the medium series

GIST_ID="9b6f1a273328280533b4feaac12dd829"
GIST_BASE_URL="https://gist.github.com/sebradloff/${GIST_ID}"

GATEKEEPER_POLICY_MANIFESTS_TMP_DIR="/tmp/gatekeeper-policy-manifests"

rm -rf "${GATEKEEPER_POLICY_MANIFESTS_TMP_DIR}"
mkdir -p "${GATEKEEPER_POLICY_MANIFESTS_TMP_DIR}"

for file_path in $(find policies -type f ! -path "policies/lib/*"); do
    new_file_name=$(echo "${file_path}" | sed -e 's|/|\-|g' -e 's/policies-//gI')
    new_file_path="${GATEKEEPER_POLICY_MANIFESTS_TMP_DIR}/${new_file_name}"
    cp "${file_path}" "${new_file_path}"

    gh gist edit --add "${new_file_path}" "${GIST_ID}"

    medium_gist_url="${GIST_BASE_URL}?ts=2&file=${new_file_name}"
    echo "${medium_gist_url}"
done