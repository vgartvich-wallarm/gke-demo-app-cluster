DOMAIN=$1

usage() {
	echo "Use the script to send several coded web attacks to Nginx service running
	on domain name specified as the only parameter of the script."
}

if [ -z "$DOMAIN" ]; then
	usage
	exit 1
fi

if [ ! -z "$2" ]; then
	IP="-H X-Forwarded-For:$2"
fi

# Open redirect attack
curl -v $IP "http://$DOMAIN/redirect?url=https://wallarm.com/"

# Information disclosure
curl -v $IP "http://$DOMAIN/.git/config"
curl -v $IP "http://$DOMAIN/index.php"
curl -v $IP "http://$DOMAIN/Dockerfile"
curl -v $IP "http://$DOMAIN/.gitignore"
curl -v $IP "http://$DOMAIN/metrics"

