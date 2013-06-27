Newrelic Plugin Script
========

As a POC I have created a very basic bash script that takes the output from varnishstat and posts the metrics to the newrelic plugin API. For configuration all that is required is to change the license key and guid (review the plugin documentation at new relic for GUID info).

The script takes the XML output from varnish stat converts it into JSON format and submits via a post, runnign this on a cron every 60 seconds gives a quick and easy monitoring solutions (provided you setup the approprate graphs etc on the new relic interface).

Althought the varnishstat binary has the option for JSON output in newer versions, the base repository version available to redhat doesn't have this functionality by default, hence the conversion.
