KONSTRAINT_VERSION := v0.14.2
KONSTRAINT_IMAGE := ghcr.io/plexsystems/konstraint:$(KONSTRAINT_VERSION)

OPA_VERSION := 0.29.4
OPA_IMAGE := openpolicyagent/opa:$(OPA_VERSION)

ALPINE_GIT_VERSION := v2.30.2
ALPINE_GIT_IMAGE := alpine/git:$(ALPINE_GIT_VERSION)

.PHONY: help
default: help
help: ## Show this help
	@echo "k8s-gatekeeper-policies-example"
	@echo "======================"
	@echo
	@echo "Creation of policies to apply to k8s clusters"
	@echo
	@fgrep -h " ## " $(MAKEFILE_LIST) | fgrep -v fgrep | sed -Ee 's/([a-z.]*):[^#]*##(.*)/\1##\2/' | column -t -s "##"

.PHONY: constraints
constraints: ## create constraints
	docker run --rm -w /src -v $(PWD):/src $(KONSTRAINT_IMAGE) \
		create policies/

.PHONY: docs
docs: ## create docs
	docker run --rm -w /src -v $(PWD):/src $(KONSTRAINT_IMAGE) \
		doc policies/

.PHONY: manifests
manifests: ## migrate manifests from policies/ directory to manifests/
	docker run --rm --entrypoint sh -w /src -v $(PWD):/src $(ALPINE_GIT_IMAGE) \
		scripts/migrate_manifests.sh

.PHONY: opa_format_check
opa_format_check: ## check if any rego files need formatting
	docker run --rm -w /src -v $(PWD):/src $(OPA_IMAGE) \
		fmt policies/ --fail

.PHONY: opa_format_write
opa_format_write: ## format all rego files
	docker run --rm -w /src -v $(PWD):/src $(OPA_IMAGE) \
		fmt policies/ --write

.PHONY: opa_check
opa_check: ## check if issues with any rego files
	docker run --rm -w /src -v $(PWD):/src $(OPA_IMAGE) \
		check policies/ --ignore *.yaml --ignore *.yml

.PHONY: opa_test
opa_test: ## run rego tests
	docker run --rm -w /src -v $(PWD):/src $(OPA_IMAGE) \
		test policies/ -v --ignore *.yaml --ignore *.yml

.PHONY: manifests_diff
manifests_diff: ## run git diff check on manifests/ directory
	docker run --rm --entrypoint sh -w /src -v $(PWD):/src \
		-e DIRECTORY=manifests \
		$(ALPINE_GIT_IMAGE) \
		scripts/git_diff.sh

.PHONY: generate_all
generate_all: opa_format_write opa_test constraints manifests docs ## used for local dev to quickly iterate on changes
	@echo "ran generate_all"