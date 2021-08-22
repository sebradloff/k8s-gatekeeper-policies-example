# @title Namespaces must have a team label
#
# Required team label on all namespaces to determine ownership
#
# @enforcement deny
# @kinds core/Namespace
package namespace_team_label_01

violation[{"msg": msg, "details": {}}] {
	resource := input.review.object

	not resource.metadata.labels.team

	msg := sprintf("%s: Namespace does not have a required 'team' label", [resource.metadata.name])
}
