#!/bin/bash

DOMAINS=()
SITES_DIR="/var/www"
SITES_ENABLED_DIR="/etc/apache2/sites-enabled"
if [ -d "$SITES_DIR" ]; then
     cd $SITES_DIR;
     for i in $(ls -d */); do
         DOMAINS+=(${i%%/});
     done
fi

if [ -n "$DOMAINS" ]; then
    ## Loop through all sites
    for ((i=0; i < ${#DOMAINS[@]}; i++)); do
        ## Current Domain
        DOMAIN=${DOMAINS[$i]}
        if [ ! -f /etc/apache2/sites-available/$DOMAIN.conf ]; then
            echo "Creating config for $DOMAIN..."
            mkdir -p $SITES_DIR/$DOMAIN
            sudo cp /etc/apache2/sites-available/default-site.conf /etc/apache2/sites-available/$DOMAIN.conf
            sudo sed -i s,placeholder.dev,$DOMAIN,g /etc/apache2/sites-available/$DOMAIN.conf

            # Save some time
            if [ -d "$SITES_DIR/$DOMAIN/htdocs" ]; then
                sudo sed -i s,/var/www/placeholder,$SITES_DIR/$DOMAIN/htdocs,g /etc/apache2/sites-available/$DOMAIN.conf
            else
                sudo sed -i s,/var/www/placeholder,$SITES_DIR/$DOMAIN,g /etc/apache2/sites-available/$DOMAIN.conf
            fi

            sudo a2ensite $DOMAIN.conf
        fi
    done

    sudo service apache2 restart
fi