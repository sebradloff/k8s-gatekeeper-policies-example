# @title Enforce API Gateway Ingress path per service
#
# There should be one Ingress per service receiving requests at "/api/${resource}".
# We do not want seperate services serving traffic on the same top level path.
# We should not see "/api/foozles" and "/api/foozles/rejoice" serving traffic
# to two seperate services.
#
# @enforcement deny
# @kinds networking.k8s.io/Ingress
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
