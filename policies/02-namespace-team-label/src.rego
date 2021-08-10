# @title Namespaces must have a team label
#
# Required team label on all namespaces to determine ownership
#
# @enforcement deny
# @kinds core/Namespace
package namespace_team_label

import data.lib.core

policyID := "P0002"

violation[msg] {
	resource := input.review.object

	not resource.metadata.labels.team

	msg := core.format_with_id(sprintf("%s: Namespace does not have a required 'team' label", [core.name]), policyID)
}
