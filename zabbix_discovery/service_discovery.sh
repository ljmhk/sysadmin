#!/bin/bash
count=0
incount=$(find /etc/init.d/ -type f | wc -l)
outputfile="/tmp/service_discovery.$$"
echo '{' >> $outputfile
echo '"data":[' >> $outputfile
for instance in $(find /etc/init.d/ -type f)
    do
        count=$(($count+1))
        echo '{' >> $outputfile
        if [ "$count" -eq "$incount" ];
            then
                echo "\"{#SERVICE_NAME}\":\"$(echo $instance | awk -F/ {'print $4'})\"}" >> $outputfile
            else
                echo "\"{#SERVICE_NAME}\":\"$(echo $instance | awk -F/ {'print $4'})\"}," >> $outputfile
            fi
    done
echo ']}' >> $outputfile
cat $outputfile
rm $outputfile
