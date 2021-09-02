# @title Containers must have resource requests
#
# All containers must have resource requests so the scheduler can better binpack each node.
# Reading on managing container resources: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/
#
# @enforcement deny
# @kinds apps/DaemonSet apps/Deployment apps/StatefulSet batch/CronJob batch/Job core/Pod
package container_deny_without_resource_requests_02

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
