TF := terraform -chdir=terraform

.PHONY: help setup secrets vault-init vault-edit vault-view init fmt validate lint plan apply destroy output ssh

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-14s %s\n", $$1, $$2}'

setup: vault-init init ## Create the encrypted vault and initialize Terraform

secrets: ## Print the command that loads secrets into the current shell
	@echo 'eval "$$(./scripts/secrets.sh)"'

vault-init: ## Build ansible/vault.yml from a service account key
	./scripts/make-vault.sh

vault-edit: ## Edit the encrypted vault
	ansible-vault edit ansible/vault.yml

vault-view: ## Show the decrypted vault contents
	ansible-vault view ansible/vault.yml

init: ## Initialize Terraform and connect the remote backend
	$(TF) init

fmt: ## Format Terraform files
	$(TF) fmt -recursive

validate: ## Validate the configuration
	$(TF) validate

lint: fmt validate ## Format and validate

plan: ## Show what would change
	$(TF) plan

apply: ## Create or update the infrastructure
	$(TF) apply

destroy: ## Delete the infrastructure
	$(TF) destroy

output: ## Show the addresses of created resources
	$(TF) output

ssh: ## Connect to the first web server
	ssh ubuntu@$$($(TF) output -json web_public_ips | python3 -c 'import json,sys; print(json.load(sys.stdin)[0])')
