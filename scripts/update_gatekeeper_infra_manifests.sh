#!/bin/sh

set -eux

: "${MANIFESTS_OUTPUT_DIR:?Need to set MANIFESTS_OUTPUT_DIR}"

rm -rf "${MANIFESTS_OUTPUT_DIR}"
mkdir -p "${MANIFESTS_OUTPUT_DIR}"

HELM_VERSION="3.6.3"
HELM_IMAGE="alpine/helm:${HELM_VERSION}"

GATEKEEPER_NAMESPACE="gatekeeper-system"
GATEKEEPER_NAMESPACE_OUTPUT_DIR="${MANIFESTS_OUTPUT_DIR}/${GATEKEEPER_NAMESPACE}"
mkdir -p "${GATEKEEPER_NAMESPACE_OUTPUT_DIR}"

INGRESS_NGINX_NAMESPACE="ingress-nginx"
INGRESS_NGINX_NAMESPACE_OUTPUT_DIR="${MANIFESTS_OUTPUT_DIR}/${INGRESS_NGINX_NAMESPACE}"
mkdir -p "${INGRESS_NGINX_NAMESPACE_OUTPUT_DIR}"

# template gatekeeper chart manifests
GATEKEEPER_HELM_CHART_REPO="https://open-policy-agent.github.io/gatekeeper/charts"
GATEKEEPER_HELM_CHART_VERSION="3.5.2"
GATEKEEPER_HELM_CHART_DIR_NAME="gatekeeper"
GATEKEEPER_HELM_CHART_DIR="/tmp/${GATEKEEPER_HELM_CHART_DIR_NAME}"
GATEKEEPER_HELM_CHART_NAME="gatekeeper"
GATEKEEPER_OUTPUT_MANIFEST="${MANIFESTS_OUTPUT_DIR}/${GATEKEEPER_NAMESPACE}/${GATEKEEPER_HELM_CHART_NAME}.yml"

rm -rf "${GATEKEEPER_HELM_CHART_DIR}"

docker run -it --rm -v /tmp:/apps -w /apps "${HELM_IMAGE}" \
    pull --repo "${GATEKEEPER_HELM_CHART_REPO}" --version "${GATEKEEPER_HELM_CHART_VERSION}" \
    --untardir "${GATEKEEPER_HELM_CHART_DIR_NAME}" --untar "${GATEKEEPER_HELM_CHART_NAME}"

manifest_content=$(docker run -it --rm -v /tmp:/apps -w /apps/ "${HELM_IMAGE}" \
    template --include-crds --set replicas=1 --set auditInterval=10 --set controllerManager.resources=null \
    --set audit.resources=null --namespace gatekeeper-system \
    "${GATEKEEPER_HELM_CHART_NAME}" "${GATEKEEPER_HELM_CHART_DIR_NAME}/${GATEKEEPER_HELM_CHART_NAME}")

echo "${manifest_content}" > "${GATEKEEPER_OUTPUT_MANIFEST}"


# template gatekeeper-policy-manager manifests
GATEKEEPER_POLICY_MANAGER_VERSION="0.5.0"
GATEKEEPER_POLICY_MANAGER_TAR_GZ_URL="https://github.com/sighupio/gatekeeper-policy-manager/archive/refs/tags/v${GATEKEEPER_POLICY_MANAGER_VERSION}.tar.gz"
GATEKEEPER_POLICY_MANAGER_HELM_CHART_DIR_NAME="gatekeeper-policy-manager"
GATEKEEPER_POLICY_MANAGER_DIR="/tmp/${GATEKEEPER_POLICY_MANAGER_HELM_CHART_DIR_NAME}"
GATEKEEPER_POLICY_MANAGER_CHART_NAME="gatekeeper-policy-manager"
GATEKEEPER_POLICY_MANAGER_OUTPUT_MANIFEST="${MANIFESTS_OUTPUT_DIR}/${GATEKEEPER_NAMESPACE}/${GATEKEEPER_POLICY_MANAGER_CHART_NAME}.yml"

rm -rf "${GATEKEEPER_POLICY_MANAGER_DIR}"
mkdir -p "${GATEKEEPER_POLICY_MANAGER_DIR}"

curl -sL "${GATEKEEPER_POLICY_MANAGER_TAR_GZ_URL}" | tar -xf - \
    --strip-components=2 -C "${GATEKEEPER_POLICY_MANAGER_DIR}" \
    "${GATEKEEPER_POLICY_MANAGER_CHART_NAME}-${GATEKEEPER_POLICY_MANAGER_VERSION}/chart/" 

manifest_content=$(docker run -it --rm -v /tmp:/apps -w /apps/ "${HELM_IMAGE}" \
    template --namespace gatekeeper-system --set config.secretKey="test" --set replicaCount=1 --set resources=null \
    "${GATEKEEPER_POLICY_MANAGER_CHART_NAME}" "${GATEKEEPER_POLICY_MANAGER_HELM_CHART_DIR_NAME}")

echo "${manifest_content}" > "${GATEKEEPER_POLICY_MANAGER_OUTPUT_MANIFEST}"


# kind ingress-nginx controller
INGRESS_NGINX_VERSION="v0.47.0"
INGRESS_NGINX_MANIFEST_URL="https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-${INGRESS_NGINX_VERSION}/deploy/static/provider/kind/deploy.yaml"
INGRESS_NGINX_OUTPUT_MANIFEST="${MANIFESTS_OUTPUT_DIR}/${INGRESS_NGINX_NAMESPACE}/ingress-nginx.yml"

curl -sL "${INGRESS_NGINX_MANIFEST_URL}" -o "${INGRESS_NGINX_OUTPUT_MANIFEST}"