#!/bin/bash
function configuration {
    LICENSE="XXXXXX"
    LOGFILE="/var/log/newrelic/varnish_plugin.log"
    JSONFILE="/tmp/vnsh_json.tmp"
    APIURL="https://platform-api.newrelic.com/platform/v1/metrics"
    HOSTNAME=$(hostname)
    APPNAME="Varnish"
    PID="$$"
    GUID="XXXXXX"
}

function gather_metrics {
    /usr/bin/varnishstat -f cache_hit,cache_miss,backend_conn,backend_unhealthy,backend_busy,backend_fail,backend_unused,backend_req,backend_retry,client_conn,client_req,client_drop -x | awk -F'\t' {'print $3'} | egrep -i "name|value" | tr '\n' ' ' | sed 's/<[name>]\+>/"Component\/Varnish\//g' | sed 's/<[/name>]\+>/\[Total\]"/g' | sed 's/<[value>]\+>/: \[/g'| sed 's/<\/value>/\n/g' | sed 's/ //g' | awk -F[ {'print $1"["$2""$3","'}
    /usr/bin/varnishstat -f uptime -x | awk -F'\t' {'print $3'} | egrep -i "name|value" | tr '\n' ' ' | sed 's/<[name>]\+>/"Component\/Varnish\//g' | sed 's/<[/name>]\+>/\[Total\]"/g' | sed 's/<[value>]\+>/: \[/g'| sed 's/<\/value>/\n/g' | sed 's/ //g' | awk -F[ {'print $1"["$2""$3""'}
}

function writejson {
    echo "{
\"agent\": {
    \"host\" : \"$HOSTNAME\",
    \"pid\" : $PID,
    \"version\" : \"1.0.0\"
},
\"components\": [
    {
      \"name\": \"$APPNAME\",
      \"guid\": \"$GUID\",
      \"duration\" : 60,
      \"metrics\" : {" >> $JSONFILE
gather_metrics >> $JSONFILE
echo '}
      }
  ]
}' >> $JSONFILE
}

function apipost {
    /usr/bin/curl --silent $APIURL -H "X-License-Key: $LICENSE" -H "Content-Type: application/json" -H "Accept: application/json" -X POST -d "$(cat $JSONFILE)" > /dev/null
}
function cleanup {
    rm -rf $JSONFILE
}

configuration
writejson
apipost
cleanup
