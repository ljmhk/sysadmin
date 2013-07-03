#!/bin/bash
    tmpfile_cat="/tmp/dataset_cat.$$"
    tmpfile_prod="/tmp/dataset_prod.$$"
    tmpfile_srch="/tmp/dataset_srch.$$"
    tmpfile_basic_prod="/tmp/dataset_baseprod.$$"
    tmpfile_brands="/tmp/dataset_brandid.$$"
    magepath=$1
    if [ -z $1 ];
        then
            echo "Supply path to magento instance"
            exit 1
        fi
    dbuser=$(grep -m 1 'username' $magepath/app/etc/local.xml | awk -F[ {'print $3'} | awk -F] {'print $1'})
    dbpass=$(grep -m 1 'password' $magepath/app/etc/local.xml | awk -F[ {'print $3'} | awk -F] {'print $1'})
    dbname=$(grep -m 1 'dbname' $magepath/app/etc/local.xml | awk -F[ {'print $3'} | awk -F] {'print $1'})
    dbhost=$(grep -m 1 'host' $magepath/app/etc/local.xml | awk -F[ {'print $3'} | awk -F] {'print $1'})
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
    echo product_id,product_url >> $tmpfile_basic_prod
    mysql --silent -N -h$dbhost -u$dbuser $dbpass $dbname -e "select CONCAT_WS(',', entity_id, url_path) from catalog_product_flat_1 where colour IS NULL AND size IS NULL AND has_options=0;" >> $tmpfile_basic_prod
    mv $tmpfile_basic_prod ./cart_products.csv
    echo url_key,brand_id >> $tmpfile_brands
    mysql --silent -N -h$dbhost -u$dbuser $dbpass $dbname -e "select CONCAT_WS(',', url_key, brand_id) from brands_brand;" >> $tmpfile_brands
    mv $tmpfile_brands ./brand_ids.csv
