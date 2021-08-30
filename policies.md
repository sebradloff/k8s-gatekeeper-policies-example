# Policies

## Violations

* [Namespaces must have a team label](#namespaces-must-have-a-team-label)
* [P0002: Namespaces must have a team label](#p0002-namespaces-must-have-a-team-label)

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
