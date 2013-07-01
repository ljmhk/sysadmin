Zabbix Service Discovery 
========

In an attempt to simplify the zabbix configuration process I have created a simply script to gather a list of services installed on the system and return these values in json format. This process then allows for the custom script to be run as a discovery rule in zabbix, this enables the use of prototype checks on the system. In short this simple script enables zabbix to determine which checks and triggers it should apply to host based on the services it is running rather than manual template assignment.

The script is very basic but does require some setup, firstly remote commands must be abled for the zabbix agent. Secondly a regular expression set needs to be created in the zabbix interface (Administration > General > Regular expressions) For example the following regex would return a set of core services to monitor:

^(memcached|redis|newrelic-daemon|newrelic-sysmond|varnish|httpd|mysql)$

Lastly a discovery rule set needs to be created wit hthe following key:

system.run[/path/to/script]

This will then allow you to build prototype items triggers and graphs based on the results, for example checking "redis-cli info" for specific values with the regex checks built into zabbix.
