package container_deny_without_resource_requests_01

test_input_as_pod_both_containers_missing_resource_requests {
	c1_resources := {}
	c2_resources := {}
	input := {"review": {"object": pod_input(c1_resources, c2_resources)}}

	results := violation with input as input

	count(results) == 2
}

test_input_as_pod_one_container_missing_resources {
	c1_resources := {"requests": {"cpu": "10m", "memory": "100Mi"}}
	c2_resources := {}
	input := {"review": {"object": pod_input(c1_resources, c2_resources)}}

	results := violation with input as input

	count(results) == 1
}

test_input_as_pod_one_container_zero_cpu {
	c1_resources := {"requests": {"cpu": "10m", "memory": "100Mi"}}
	c2_resources := {"requests": {"cpu": "0m", "memory": "100Mi"}}
	input := {"review": {"object": pod_input(c1_resources, c2_resources)}}

	results := violation with input as input

	count(results) == 1
}

test_input_as_pod_one_container_zero_memory {
	c1_resources := {"requests": {"cpu": "10m", "memory": "100Mi"}}
	c2_resources := {"requests": {"cpu": "10m", "memory": "0Mi"}}
	input := {"review": {"object": pod_input(c1_resources, c2_resources)}}

	results := violation with input as input

	count(results) == 1
}

test_input_as_pod_one_container_zero_cpu_and_zero_memory {
	c1_resources := {"requests": {"cpu": "10m", "memory": "100Mi"}}
	c2_resources := {"requests": {"cpu": "0m", "memory": "0Mi"}}
	input := {"review": {"object": pod_input(c1_resources, c2_resources)}}

	results := violation with input as input

	count(results) == 2
}

test_input_as_pod_all_resource_requests_set_properly {
	c1_resources := {"requests": {"cpu": "10m", "memory": "100Mi"}}
	c2_resources := {"requests": {"cpu": "10m", "memory": "100Mi"}}
	input := {"review": {"object": pod_input(c1_resources, c2_resources)}}

	results := violation with input as input

	count(results) == 0
}

pod_input(c1_resources, c2_resources) = output {
	output = {
		"kind": "Pod",
		"metadata": {"name": "test"},
		"spec": {"containers": [
			{
				"name": "test-1",
				"image": "busybox",
				"resources": c1_resources,
			},
			{
				"name": "test-2",
				"image": "busybox",
				"resources": c2_resources,
			},
		]},
	}
}
