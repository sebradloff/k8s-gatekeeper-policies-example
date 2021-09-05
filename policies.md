# Policies

## Violations

* [Namespaces must have a team label](#namespaces-must-have-a-team-label)
* [P0002: Namespaces must have a team label](#p0002-namespaces-must-have-a-team-label)
* [P0003: Containers must have resource requests](#p0003-containers-must-have-resource-requests)
* [P0004: Containers must have resource requests](#p0004-containers-must-have-resource-requests)
* [P0005: Enforce API Gateway Ingress path per service](#p0005-enforce-api-gateway-ingress-path-per-service)

## Namespaces must have a team label

**Severity:** Violation

**Resources:** core/Namespace

Required team label on all namespaces to determine ownership

### Rego

```rego
package namespace_team_label_01

violation[{"msg": msg, "details": {}}] {
  resource := input.review.object

  not resource.metadata.labels.team

  msg := sprintf("%s: Namespace does not have a required 'team' label", [resource.metadata.name])
}
```

_source: [policies/namespace-team-label-01](policies/namespace-team-label-01)_

## P0002: Namespaces must have a team label

**Severity:** Violation

**Resources:** core/Namespace

Required team label on all namespaces to determine ownership

### Rego

```rego
package namespace_team_label_02

import data.lib.core

policyID := "P0002"

default has_team_label = false

has_team_label {
  core.has_field(core.labels, "team")
}

violation[msg] {
  not has_team_label

  msg := core.format_with_id(sprintf("%s: Namespace does not have a required 'team' label", [core.name]), policyID)
}
```

_source: [policies/namespace-team-label-02](policies/namespace-team-label-02)_

## P0003: Containers must have resource requests

**Severity:** Violation

**Resources:** core/Pod

All containers must have resource requests so the scheduler can better binpack each node.
Reading on managing container resources: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/

### Rego

```rego
package container_deny_without_resource_requests_01

import data.lib.core
import data.lib.pods

policyID := "P0003"

violation[msg] {
  container := pods.containers[_]
  not container_requests_provided(container)

  msg := core.format_with_id(sprintf("%s/%s/%s: Container resource requests cpu and memory must be specified", [core.kind, core.name, container.name]), policyID)
}

violation[msg] {
  container := pods.containers[_]
  not container_requests_zero_memory(container)

  msg := core.format_with_id(sprintf("%s/%s/%s: Container resource memory requests can not have zero value (%s)", [core.kind, core.name, container.name, container.resources.requests.memory]), policyID)
}

violation[msg] {
  container := pods.containers[_]
  not container_requests_zero_cpu(container)

  msg := core.format_with_id(sprintf("%s/%s/%s: Container resource cpu requests can not have zero value (%s)", [core.kind, core.name, container.name, container.resources.requests.cpu]), policyID)
}

container_requests_provided(container) {
  container.resources.requests.cpu
  container.resources.requests.memory
}

container_requests_zero_memory(container) {
  not regex.match("^0.*", container.resources.requests.memory)
}

container_requests_zero_cpu(container) {
  not regex.match("^0.*", container.resources.requests.cpu)
}
```

_source: [policies/container-deny-without-resource-requests-01](policies/container-deny-without-resource-requests-01)_

## P0004: Containers must have resource requests

**Severity:** Violation

**Resources:** apps/DaemonSet apps/Deployment apps/StatefulSet batch/CronJob batch/Job core/Pod

All containers must have resource requests so the scheduler can better binpack each node.
Reading on managing container resources: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/

### Rego

```rego
package container_deny_without_resource_requests_02

import data.lib.core
import data.lib.pods

policyID := "P0004"

violation[msg] {
  container := pods.containers[_]
  not container_requests_provided(container)

  msg := core.format_with_id(sprintf("%s/%s/%s: Container resource requests cpu and memory must be specified", [core.kind, core.name, container.name]), policyID)
}

violation[msg] {
  container := pods.containers[_]
  not container_requests_zero_memory(container)

  msg := core.format_with_id(sprintf("%s/%s/%s: Container resource memory requests can not have zero value (%s)", [core.kind, core.name, container.name, container.resources.requests.memory]), policyID)
}

violation[msg] {
  container := pods.containers[_]
  not container_requests_zero_cpu(container)

  msg := core.format_with_id(sprintf("%s/%s/%s: Container resource cpu requests can not have zero value (%s)", [core.kind, core.name, container.name, container.resources.requests.cpu]), policyID)
}

container_requests_provided(container) {
  container.resources.requests.cpu
  container.resources.requests.memory
}

container_requests_zero_memory(container) {
  not regex.match("^0.*", container.resources.requests.memory)
}

container_requests_zero_cpu(container) {
  not regex.match("^0.*", container.resources.requests.cpu)
}
```

_source: [policies/container-deny-without-resource-requests-02](policies/container-deny-without-resource-requests-02)_

## P0005: Enforce API Gateway Ingress path per service

**Severity:** Violation

**Resources:** networking.k8s.io/Ingress

There should be one Ingress per service receiving requests at "/api/${resource}".
We do not want seperate services serving traffic on the same top level path.
We should not see "/api/foozles" and "/api/foozles/rejoice" serving traffic
to two seperate services.

### Rego

```rego
package api_gateway_ingress_path_01

import data.lib.core

policyID := "P0005"

identical(obj, resource) {
  obj.metadata.namespace == resource.metadata.namespace
  obj.metadata.name == resource.metadata.name
}

paths_conflict(path1, path2) = result {
  path1_sub_api := trim_prefix(path1, "/api/")
  path2_sub_api := trim_prefix(path2, "/api/")

  # split by '/' because the characted can not be interpreted by rego regex which uses re2
  # https://github.com/google/re2/wiki/Syntax
  path1_arr := split(path1_sub_api, "/")
  path2_arr := split(path2_sub_api, "/")

  path1_arr_rsplit := regex.split("[^\\w|-]+", path1_arr[0])
  path2_arr_rsplit := regex.split("[^\\w|-]+", path2_arr[0])

  result := path1_arr_rsplit[0] == path2_arr_rsplit[0]
}

violation[msg] {
  ns := data.inventory.cluster.v1.Namespace[_].metadata.name
  other_ing := data.inventory.namespace[ns]["networking.k8s.io/v1"].Ingress[_]

  curr_ing := core.resource
  not identical(other_ing, curr_ing)

  curr_ing_path := curr_ing.spec.rules[_].http.paths[_].path
  other_ing_path := other_ing.spec.rules[_].http.paths[_].path

  paths_conflict(curr_ing_path, other_ing_path)

  msg := core.format_with_id(sprintf("%s/%s: http rule with path %s conflicts with %s/%s http rule path %s", [curr_ing.metadata.namespace, curr_ing.metadata.name, curr_ing_path, other_ing.metadata.namespace, other_ing.metadata.name, other_ing_path]), policyID)
}
```

_source: [policies/api-gateway-ingress-path-01](policies/api-gateway-ingress-path-01)_
