#!/bin/bash
# List of bad passwords to test for
badpasswd=(password password123)
# Temp file,log file,vhost paths and check type
logfile="/var/log/user_check.log"
tempfile="/tmp/logintest.txt"
vhost_path="/var/www/development"
zabbix="$1"
#Password testing in zabbix mode
function passcheck_zab()
{
    returnval="0"
# Loop through users found in admin_user
    for magento_user in $(mysql -N -B -h$dbhost -u $dbuser -p$dbpass $dbname -e "select username from admin_user;")
    do
# Loop through each of the Bad passwords 
        for password in ${badpasswd[@]}
            do
                curl -s --cookie cookies.txt --cookie-jar cookies.txt --user-agent Mozilla/4.0 --data "login[username]=$magento_user&login[password]=$password" ${baseurl}index.php/$admin/ -o $tempfile
# Output tests, return FAIL or PASS on result
                if [ ! -s $tempfile ];
                    then
                        echo -e "$instance failure: $magento_user login successful for password: $password" >> $logfile
# Set return value to 1 for any failures 
                        returnval="1"
                    fi
                rm cookies.txt 2>/dev/null
            done
    done
# output overall test results 0 = no problem, 1 = problem
    echo $returnval
}
#Password testing in stdout mode
function passcheck() 
{
# Loop through users found in admin_user
    for magento_user in $(mysql -N -B -h$dbhost -u $dbuser -p$dbpass $dbname -e "select username from admin_user;")
        do
            echo "Testing login: $magento_user"
# Loop through each of the Bad passwords 
            for password in ${badpasswd[@]}
                do
                    curl -s --cookie cookies.txt --cookie-jar cookies.txt --user-agent Mozilla/4.0 --data "login[username]=$magento_user&login[password]=$password" ${baseurl}index.php/$admin/ -o $tempfile
# Output tests, return FAIL or PASS on result
                    if [ -s $tempfile ];
                        then
                            echo -e "\E[32mPASS $password" 
                            rm $tempfile
                        else
                            echo -e "\E[31mFAIL $password"
                            echo -e "$instance failure: $magento_user login successful for password: $password" >> $logfile
                        fi
                    echo -e "\E[00m" 
                    rm cookies.txt 2>/dev/null
                done
        done
}
# Parameter tests
if [ ! -d "$vhost_path/app" ];
    then
        echo "Unable to find app in $vhost_path"
        exit 1
    fi
# Installation directory, database details, admin login location and baseurl
dbuser=$(grep -m 1 'username' ${vhost_path}/app/etc/local.xml | awk -F[ {'print $3'} | awk -F] {'print $1'})
dbpass=$(grep -m 1 'password' ${vhost_path}/app/etc/local.xml | awk -F[ {'print $3'} | awk -F] {'print $1'})
dbname=$(grep -m 1 'dbname' ${vhost_path}/app/etc/local.xml | awk -F[ {'print $3'} | awk -F] {'print $1'})
dbhost=$(grep -m 1 'host' ${vhost_path}/app/etc/local.xml | awk -F[ {'print $3'} | awk -F] {'print $1'})
admin=$(grep -m 1 'frontName' ${vhost_path}/app/etc/local.xml | awk -F[ {'print $3'} | awk -F] {'print $1'})
baseurl=$(mysql -N -B -h$dbhost -u $dbuser -p$dbpass $dbname -e 'select value from core_config_data where path="web/secure/base_url";')
# Decide what run type
if [ -z "$zabbix" ];
    then
        passcheck
    else
        passcheck_zab
    fi
-
