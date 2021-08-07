package namespace_team_label

test_namespace_without_team_label_is_violation {
	input := {"review": {"object": {
		"kind": "Namespace",
		"metadata": {"labels": {"not": "important"}},
		"name": "test",
	}}}

	results := violation with input as input
	count(results) > 0
}

test_namespace_without_labels_is_violation {
	input := {"review": {"object": {
		"kind": "Namespace",
		"metadata": {},
		"name": "test",
	}}}

	results := violation with input as input
	count(results) > 0
}

test_namespace_with_team_label_is_not_violation {
	input := {"review": {"object": {
		"kind": "Namespace",
		"metadata": {"labels": {"team": "core"}},
		"name": "test",
	}}}

	results := violation with input as input
	count(results) == 0
}
