init:
	terraform init

plan:
	terraform plan -out plan.plan 

apply:
	terraform apply

start: init plan apply

clean:
	rm -f terraform.tfstate terraform.tfstate.backup

	rm -rf .terraform/

	minikube delete --all