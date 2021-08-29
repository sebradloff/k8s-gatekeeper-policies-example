# @title Namespaces must have a team label
#
# Required team label on all namespaces to determine ownership
#
# @enforcement deny
# @kinds core/Namespace
package namespace_team_label_02

import data.lib.core

policyID := "P0002"

policyMsg := "Namespace does not have a required 'team' label"

violation[msg] {
	core.missing_field(core, "labels")

	msg := core.format_with_id(sprintf("%s: %s", [core.name, policyMsg]), policyID)
}

violation[msg] {
	core.missing_field(core.labels, "team")

	msg := core.format_with_id(sprintf("%s: %s", [core.name, policyMsg]), policyID)
}
