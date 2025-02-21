# Variables
TF_DIR = envs/local
CACHE_FILES = .terragrunt-cache .terraform.lock.hcl
STATE_FILES = .terraform terraform.tfstate terraform.tfstate.backup

# Argument parsing
args = $(foreach a,$($(subst -,_,$1)_args),$(if $(value $a),$a="$($a)"))

# Setup hooks
setup-hooks:
	cp .hooks/* .git/hooks
	chmod -R +x .git/hooks

# Clean Terraform caches with confirmation
tf-clean-cache:
	@read -p "Are you sure you want to delete Terraform cache? (y/N) " confirm && [ "$$confirm" = "y" ] && $(MAKE) clean-files FILES="$(CACHE_FILES)" || echo "Canceled"

tf-clean-cache-and-state:
	@read -p "Are you sure you want to delete Terraform cache AND state files? (y/N) " confirm && [ "$$confirm" = "y" ] && $(MAKE) clean-files FILES="$(CACHE_FILES) $(STATE_FILES)" || echo "Canceled"

clean-files:
	@for file in $(FILES); do \
		find . -type d -name "$$file" -prune -exec rm -rf {} \;; \
		find . -type f -name "$$file" -prune -exec rm -rf {} \;; \
	done
	find . -empty -type d -delete
	@echo "Cleanup completed."

# Terraform commands
tf-init:
	cd $(TF_DIR); terraform init -upgrade

tf-plan:
	cd $(TF_DIR); terraform plan

tf-apply:
	cd $(TF_DIR); terraform apply

tf-apply-approve:
	cd $(TF_DIR); terraform apply -auto-approve

tf-destroy:
	cd $(TF_DIR); terraform destroy

tf-destroy-approve:
	cd $(TF_DIR); terraform destroy -auto-approve

tf-graph:
	cd $(TF_DIR); terraform graph | dot -Tpng -o graph.png

# Full reset: Clean caches + Init + Apply
tf-recreate:
	$(MAKE) tf-destroy; \
	$(MAKE) tf-apply-approve; 

# Full reset: Clean caches + Init + Apply
tf-reset:
	$(MAKE) tf-destroy; \
	$(MAKE) tf-clean-cache-and-state; \
	$(MAKE) tf-init; \
	$(MAKE) tf-apply-auto-approve;
