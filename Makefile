args = $(foreach a,$($(subst -,_,$1)_args),$(if $(value $a),$a="$($a)"))

setup-hooks:
	cp .hooks/* .git/hooks
	chmod -R +x .git/hooks

clean-cache:
	find . -type d -name ".terragrunt-cache" -prune -exec rm -rf {} \;
	find . -type f -name ".terraform.lock.hcl" -prune -exec rm -rf {} \;
	find . -empty -type d -delete

terraform-init-local:
	cd envs/local; terraform init -upgrade

terraform-init-plan:
	cd envs/local; terraform plan

terraform-apply:
	cd envs/local; terraform apply

terraform-apply-auto-approve:
	cd envs/local; terraform apply -auto-approve
