

pull-kubectl-config:
	$(eval ZONE=$(shell sh -c "terraform output|cut -f2 -d=")) \
	gcloud container clusters get-credentials tf-gke-demo-app-cluster --zone=${ZONE}

init:
	terraform init

plan:
	terraform plan

apply:
	terraform apply

destroy:
	terraform destroy
