package api_gateway_ingress_path_01

test_paths_conflict_same_paths_returns_true {
	test_paths := ["/api/foozles", "/api/foozles"]

	results := paths_conflict(test_paths[0], test_paths[1])

	results == true
}

test_paths_conflict_same_root_path_returns_true {
	test_paths := ["/api/foozles", "/api/foozles/bar"]

	results := paths_conflict(test_paths[0], test_paths[1])

	results == true
}

test_paths_conflict_diff_root_path_returns_false {
	test_paths := ["/api/foozles-bar", "/api/foozles/bar"]

	results := paths_conflict(test_paths[0], test_paths[1])

	results == false
}

test_input_as_conflicting_ingresses_throws_violation {
	cluster_inv := {"v1": {"Namespace": [create_namespace("default"), create_namespace("foo")]}}

	ns_inv := {"foo": {"networking.k8s.io/v1": {"Ingress": [create_ingress("foozles", "foo", "/api/foozles(/|$)(.*)"), create_ingress("foo", "foo", "/api/foo(/|$)(.*)")]}}}

	input := {"review": {"object": create_ingress("foozles-bar", "foo", "/api/foozles/bar(/|$)(.*)")}}

	results := violation with input as input with data.inventory.cluster as cluster_inv with data.inventory.namespace as ns_inv

	count(results) == 1
}

test_input_non_conflicting_ingress_no_violations {
	cluster_inv := {"v1": {"Namespace": [create_namespace("default"), create_namespace("foo"), create_namespace("bar")]}}

	ns_inv := {"foo": {"networking.k8s.io/v1": {"Ingress": [create_ingress("foozles", "foo", "/api/foozles(/|$)(.*)"), create_ingress("foo", "foo", "/api/foo(/|$)(.*)")]}}}

	input := {"review": {"object": create_ingress("bar", "bar", "/api/bar(/|$)(.*)")}}

	results := violation with input as input with data.inventory.cluster as cluster_inv with data.inventory.namespace as ns_inv

	count(results) == 0
}

test_input_ingress_already_on_cluster_no_violation {
	cluster_inv := {"v1": {"Namespace": [create_namespace("default"), create_namespace("foo")]}}

	ns_inv := {"foo": {"networking.k8s.io/v1": {"Ingress": [create_ingress("foozles", "foo", "/api/foozles(/|$)(.*)"), create_ingress("foo", "foo", "/api/foo(/|$)(.*)")]}}}

	input := {"review": {"object": create_ingress("foozles", "foo", "/api/foozles(/|$)(.*)")}}

	results := violation with input as input with data.inventory.cluster as cluster_inv with data.inventory.namespace as ns_inv

	count(results) == 0
}

create_ingress(name, namespace, path) = ing {
	ing := {
		"apiVersion": "networking.k8s.io/v1",
		"kind": "Ingress",
		"metadata": {
			"annotations": {"nginx.ingress.kubernetes.io/rewrite-target": "/$2"},
			"name": name,
			"namespace": namespace,
		},
		"spec": {"rules": [{"http": {"paths": [{
			"pathType": "Prefix",
			"path": path,
			"backend": {"service": {
				"name": "foo",
				"port": {"number": 80},
			}},
		}]}}]},
	}
}

create_namespace(name) = ns {
	ns := {
		"apiVersion": "v1",
		"kind": "Namespace",
		"metadata": {"name": name},
		"spec": {"finalizers": ["kubernetes"]},
	}
}
