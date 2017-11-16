#!/bin/bash

parse_yaml() {
   local prefix=$2
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
   sed -ne "s|^\($s\)\($w\)$s:$s\"\(.*\)\"$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
   awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
         printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
      }
   }'
}

CONFIG_PATH="/root/sites_config.yml"
DOMAINS=()
CONFIG="$(<$CONFIG_PATH)"

eval $(parse_yaml $CONFIG_PATH "sites_")


while read -r line; do
    if [[ $line =~ ^[a-zA-Z0-9]+:$ ]]; then
        DOMAINS+=("${line::${#line}-1}")
    fi
done <<< "$CONFIG"

if [ -n "$DOMAINS" ]; then
    ## Loop through all sites
    for ((i=0; i < ${#DOMAINS[@]}; i++)); do
        ## Current Domain

        DOMAIN=${DOMAINS[$i]};
        path="sites_${DOMAIN}_path";
        domain="sites_${DOMAIN}_domain";
        if [ ! -f /etc/apache2/sites-available/"${!domain}".conf ]; then
            echo "Creating config for ${!domain}..."
            mkdir -p "${!path}"
            cp /etc/apache2/sites-available/default-site.conf /etc/apache2/sites-available/"${!domain}".conf
            sed -i s,placeholder.dev,"${!domain}.dev",g /etc/apache2/sites-available/"${!domain}".conf

            # Save some time
            if [ -d "${!path}/htdocs" ]; then
                sed -i s,/var/www/placeholder,"${!path}"/htdocs,g /etc/apache2/sites-available/"${!domain}".conf
            else
                sed -i s,/var/www/placeholder,"${!path}",g /etc/apache2/sites-available/"${!domain}".conf
            fi

            # Enable HTTPS if cert is present
            if [ -f /etc/apache2/certs/"${!domain}".cert ]; then
                sed -i s,placeholder.cert,"${!domain}".cert,g /etc/apache2/sites-available/"${!domain}".conf
                sed -i s,#/,,g /etc/apache2/sites-available/"${!domain}".conf
            fi

            a2ensite "${!domain}".conf
        fi
    done

    service apache2 restart
fi
