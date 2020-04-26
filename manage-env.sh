#!/bin/bash


log_message () {
        SEVERITY=$1
        MESSAGE="$2"
        echo `date`: "$SEVERITY" "$MESSAGE"
}


usage() {
        echo "Usage: 

        Supported parameters (only one should be specified):
                -h
                        This help message.
                update_all
                        Update all components of the project.
                update_gke
                        Update the GKE component.
                update_system
                        Update all K8s system components.
                update_dns
                        Update the DNS section.
                update_apps
                        Update all demo applications.
                update_scanner
                        Update all scanner components."
}

update_gke() {
	cd terraform/gke
	make init
	make apply
	make pull-kubectl-config
	cd ../..
}

update_dns() {
        cd terraform/dns
        terraform init
        terraform apply
        cd ../..
}

update_apps() {
	cd terraform/demo-apps/dvwa
	terraform init
	terraform apply
	
	cd ../wordpress
	terraform init
	terraform apply

	cd ../suitecrm
	terraform init
	terraform apply

	cd ../echo-server
	terraform init
	terraform apply

	cd ../tiredful-api
	terraform init
	terraform apply

	cd ../mutillidae
	terraform init
	terraform apply

	cd ../../..
}

update_scanners() {
	cd terraform/scanners/gotestwaf
	terraform init
	terraform apply

	cd ../nikto
	terraform init
	terraform apply

	cd ../sqlmap
	terraform init
	terraform apply

	cd ../scripts
	terraform init
	terraform apply

	cd ../../..
}

update_system() {
        cd terraform/system-apps/prometheus/
        terraform init
        terraform apply

        cd ../grafana
        terraform init
        terraform apply

        cd ../wallarm-ingress/
        terraform init
        terraform apply

        cd ../external-dns/
        terraform init
        terraform apply

        cd ../cert-manager/
        terraform init
        terraform apply

        cd ../../..
}

update_all() {
	update_gke

	update_dns

	update_system
	
	update_apps
	
	update_scanners
}


COMMAND=$1

case $COMMAND in
        '-h')
		usage
		exit 0
		;;
	update_all)
		update_all
		exit 0
		;;
	update_apps)
		update_apps
		exit 0
		;;
	update_scanners)
		update_scanners
		exit 0
		;;
	update_system)
		update_system
		exit 0
		;;
	update_dns)
		update_dns
		exit 0
		;;
	update_gke)
		update_gke
		exit 0
		;;
	*)
		usage
		exit 1
		;;
esac

