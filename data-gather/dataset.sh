#!/bin/bash
    tmpfile_cat="/tmp/dataset_cat.$$"
    tmpfile_prod="/tmp/dataset_prod.$$"
    tmpfile_srch="/tmp/dataset_srch.$$"
    tmpfile_localxml="/tmp/local.xml.tmp"
    magepath=$1
    if [ -z $1 ];
        then
            echo "Supply path to magento instance"
            exit 1
        fi
    cat $magepath/app/etc/local.xml | sed -n '/\<connection>/,/<\/connection>/p' > $tmpfile_localxml
    dbuser=$(grep -m 1 'username' $tmpfile_localxml | awk -F[ {'print $3'} | awk -F] {'print $1'})
    dbpass=$(grep -m 1 'password' $tmpfile_localxml | awk -F[ {'print $3'} | awk -F] {'print $1'})
    dbname=$(grep -m 1 'dbname' $tmpfile_localxml | awk -F[ {'print $3'} | awk -F] {'print $1'})
    dbhost=$(grep -m 1 'host' $tmpfile_localxml | awk -F[ {'print $3'} | awk -F] {'print $1'})
    #If no mysql password then no -p flag
    if [ ! -z $dbpass ];
        then
            dbpass="-p$dbpass"
        fi
    echo product_url >> $tmpfile_prod
    mysql -N -h$dbhost -u$dbuser $dbpass $dbname -e "select url_path from catalog_product_flat_1;" >> $tmpfile_prod
    mv $tmpfile_prod ./product_url.csv
    echo catalog_url >> $tmpfile_cat
    mysql -N -h$dbhost -u$dbuser $dbpass $dbname -e "select url_path from catalog_category_flat_store_1;" >> $tmpfile_cat
    mv $tmpfile_cat ./category_url.csv
    echo search_url >> $tmpfile_srch
    mysql --silent -N -h$dbhost -u$dbuser $dbpass $dbname -e "select query_text from catalogsearch_query where num_results < 10;" >> $tmpfile_srch
    mv $tmpfile_srch ./search_url.csv

    sed -i '/NULL/d' ./product_url.csv
    sed -i '/NULL/d' ./category_url.csv
    sed -i '/NULL/d' ./search_url.csv
    sed -i '/.\{3\}/!d' ./search_url.csv
