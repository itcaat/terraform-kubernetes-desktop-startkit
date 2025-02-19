args = $(foreach a,$($(subst -,_,$1)_args),$(if $(value $a),$a="$($a)"))

setup-hooks:
	cp .hooks/* .git/hooks
	chmod -R +x .git/hooks

clean-cache:
	find . -type d -name ".terragrunt-cache" -prune -exec rm -rf {} \;
	find . -type f -name ".terraform.lock.hcl" -prune -exec rm -rf {} \;
	find . -empty -type d -delete

