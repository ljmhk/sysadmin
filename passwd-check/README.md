Mage Password check
========

A bash script which takes an array list of "bad passwords" and tests each magento user with the list of passwords to confirm their usage. The script looks in the magento local.xml to obtain the mysql login details, connects loads a list of users and the configured base url. The array of bad passwords is then "tested" for each user. The script has an additional function to run as a custom zabbix check, simply returning true or false based on the findings of the script.

Firstly this is a very basic and dirty approch to testing for bad logins, the script quite litteraly tries to login with the details and warns if the login is successful. This script isn't suitable for a long list of passwords, the magento functionality to lock accounts would most likely be triggered if too many passwords were checked or if the checks run too frequently, its pirmary purpose is to check for common development passwords that may have been left behind as part of the development process, NOT to test a whole dictionary of bad passwords. Only tested with magento EE v1.8 - v1.12.

Setup: you need to set the badpasswd varible to your list of passwords (I would recommend no more than 3 or four passwords) you would then also need to set the vhost_path varible to point to the webroot of the magento installation. To trigger a zabbix type run, simply pass the script an argument (it can be anything so long as $1 is populated a zabbix mode run will be triggered)
