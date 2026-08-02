TF := terraform -chdir=terraform

.PHONY: secrets vault-init vault-create vault-edit vault-view init fmt validate plan apply destroy

secrets:
	@echo 'eval "$$(./scripts/secrets.sh)"'

vault-init:
	./scripts/make-vault.sh

vault-create:
	ansible-vault create ansible/vault.yml

vault-edit:
	ansible-vault edit ansible/vault.yml

vault-view:
	ansible-vault view ansible/vault.yml

init:
	$(TF) init

fmt:
	$(TF) fmt -recursive

validate:
	$(TF) validate

plan:
	$(TF) plan

apply:
	$(TF) apply

destroy:
	$(TF) destroy
