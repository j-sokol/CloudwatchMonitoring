init: 
	terraform init -backend-config=$(env)/backends.tfvars
validate: 
	terraform validate -var-file=$(env)/vars.tfvars
plan: 
	terraform plan -var-file=$(env)/vars.tfvars	
apply: 
	terraform apply -var-file=$(env)/vars.tfvars -auto-approve
destroy: 
	terraform destroy -var-file=$(env)/vars.tfvars
