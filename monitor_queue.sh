#!/bin/bash
# This script is used for monitoring the ActiveMq queue for real time enrollments. 
# The queue can be montiroted by a JSON endpoint

BASENAME=$(basename $0)
reNums='^[0-9]+$' 
URL=
WARN=
CRIT=
ATTRIBUTE=
USAGE="USAGE: ./$BASENAME [-u | --url] url [-w | --warning] value [-c | --critical] value[-a | --attribute] 'queueLatency/pendingMessages'"

if [ $# -eq 0 ]; then
	echo "$USAGE"
	exit 0
fi

####### process the cmd line arguments ########
while [ $# -gt 0 ] 
do
	case "$1" in
		-w) WARN="$2"; shift
		;;
		--warning) WARN="$2"; shift
		;;
		-c) CRIT="$2"; shift
		;;
		--critical) CRIT="$2"; shift
		;; 
		-a) ATTRIBUTE="$2"; shift
		;;
		--attribute) ATTRIBUTE="$2"; shift
		;;
		-u) URL="$2"; shift
		;;
		--url) URL="$2"; shift
		;;
		-h) echo "$USAGE"; exit 0
		;;
		--help) echo "$USAGE"; exit 0
		;;
	esac
	shift
done
#############################################

if ! [[ ! -z $URL ]]; then
	echo "Need a url to connect to"
	exit 2	
fi 

if [[ ! -z $WARN ]]; then
	if ! [[ $WARN =~ $reNums ]]; then
		echo "Need a number for thresh value" >&2; exit 0
	fi
else
	echo "Need a warning thresh value"
	exit 2
fi

if [[ ! -z $CRIT ]]; then
	if ! [[ $CRIT =~ $reNums ]]; then
		echo "Need a number for thresh value" >&2; exit 0
	fi
else
	echo "Need a critical thresh value"
	exit 2
fi

if ! [[ ! -z $ATTRIBUTE ]]; then
	echo "Need an attribute to lookup"
	exit 2	
fi


curl -s $URL -o JSON
VALUE=$(grep $ATTRIBUTE JSON | cut -d ':' -f 2 | cut -d ',' -f 1)

if [ $VALUE -ge $WARN ]; then
	if [ $VALUE -ge $CRIT ]; then
		echo "CRITICAL: $ATTRIBUTE has passed thresh hold of $CRIT. $ATTRIBUTE : $VALUE" 
		exit 2
	else
		echo "WARNING: $ATTRIBUTE has passed thresh hold of $WARN but is below $CRIT. $ATTRIBUTE : $VALUE"
		exit 1
	fi
else
	echo "OK: $ATTRIBUTE is below the thresh hold of $WARN. $ATTRIBUTE : $VALUE"
fi

rm -f JSON
