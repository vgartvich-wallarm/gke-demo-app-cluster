#!/bin/bash
#
# Use the script to update all or specific components of the environment.
#

# Fail the script in case of an error
set -e

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
	log_message INFO "Updating the GKE cluster configuration..."
	cd terraform/gke
	make init
	make apply

	log_message INFO "Pulling the kubectl configuration..."
	make pull-kubectl-config
	cd ../..
}

update_dns() {
	log_message INFO "Updating the DNS zone configuration..."
        cd terraform/dns
        terraform init
        terraform apply
        cd ../..
}

update_apps() {
	log_message INFO "Updating the DVWA app configuration..."
	cd terraform/demo-apps/dvwa
	terraform init
	terraform apply

	log_message INFO "Updating the Wordpress app configuration..."
	cd ../wordpress
	terraform init
	terraform apply

	log_message INFO "Updating the SuiteCRM app configuration..."
	cd ../suitecrm
	terraform init
	terraform apply

	log_message INFO "Updating the Echo Server configuration..."
	cd ../echo-server
	terraform init
	terraform apply

	log_message INFO "Updating the Tiredful-API configuration..."
	cd ../tiredful-api
	terraform init
	terraform apply

	log_message INFO "Updating the Mutillidae II app configuration..."
	cd ../mutillidae
	terraform init
	terraform apply

	log_message INFO "Updating the simple Nginx server configuration..."
	cd ../nginx
	terraform init
	terraform apply

	cd ../../..
}

update_scanners() {
	log_message INFO "Update the GoTestWAF cronjob configuration..."
	cd terraform/scanners/gotestwaf
	terraform init
	terraform apply

	log_message INFO "Update the Nikto cronjob configuration..."
	cd ../nikto
	terraform init
	terraform apply

	log_message INFO "Update the Sqlmap cronjob configuration..."
	cd ../sqlmap
	terraform init
	terraform apply

	log_message INFO "Update the configuration of custom scripts cronjobs..."
	cd ../scripts
	terraform init
	terraform apply

	cd ../../..
}

update_system() {
	log_message INFO "Update the Prometheus configuration..."
        cd terraform/system-apps/prometheus/
        terraform init
        terraform apply

	log_message INFO "Update the Grafana configuration..."
        cd ../grafana
        terraform init
        terraform apply

	log_message INFO "Update the Grafana configuration..."
        cd ../wallarm-ingress/
        terraform init
        terraform apply

	log_message INFO "Update the External-DNS configuration..."
        cd ../external-dns/
        terraform init
        terraform apply

	log_message INFO "Update the Cert-Manager configuration..."
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

