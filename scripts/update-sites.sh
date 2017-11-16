#!/bin/bash

DOMAINS=()
SITES_DIR="/var/www"

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
        if [ ! -f /etc/apache2/sites-available/"$DOMAIN".conf ]; then
            echo "Creating config for $DOMAIN..."
            mkdir -p "$SITES_DIR"/"$DOMAIN"
            cp /etc/apache2/sites-available/default-site.conf /etc/apache2/sites-available/"$DOMAIN".conf
            sed -i s,placeholder.dev,"$DOMAIN",g /etc/apache2/sites-available/"$DOMAIN".conf

            # Save some time
            if [ -d "$SITES_DIR/$DOMAIN/htdocs" ]; then
                sed -i s,/var/www/placeholder,"$SITES_DIR"/"$DOMAIN"/htdocs,g /etc/apache2/sites-available/"$DOMAIN".conf
            else
                sed -i s,/var/www/placeholder,"$SITES_DIR"/"$DOMAIN",g /etc/apache2/sites-available/"$DOMAIN".conf
            fi

            # Enable HTTPS if cert is present
            if [ -f /etc/apache2/certs/"$DOMAIN".cert ]; then
                sed -i s,placeholder.cert,"$DOMAIN".cert,g /etc/apache2/sites-available/"$DOMAIN".conf
                sed -i s,#/,,g /etc/apache2/sites-available/"$DOMAIN".conf
            fi

            a2ensite "$DOMAIN".conf
        fi
    done

    service apache2 restart
fi
