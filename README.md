## installation
- run ```cp default.sites_config.yml sites_config.yml``` and add drupal 8 apache site configs.
- run ```docker-compose build```
- run ```docker-compose up -d ```
- run ```docker exec -it apache_d8 /root/update-sites-from-config.sh```
- run ```sudo vim /etc/hosts``` and add site settings

