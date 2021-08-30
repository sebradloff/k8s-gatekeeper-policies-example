# @title Namespaces must have a team label
#
# Required team label on all namespaces to determine ownership
#
# @enforcement deny
# @kinds core/Namespace
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
