FROM ubuntu:16.04
MAINTAINER Devin Lumley <devin@highwaythreesolutions.com>

# Setup environment
ENV DEBIAN_FRONTEND noninteractive

# Update sources
RUN apt-get update -y

# install http
RUN apt-get install -y apache2 vim bash-completion unzip curl
RUN mkdir -p /var/lock/apache2 /var/run/apache2

# install php

RUN apt-get install -y php7.0 libapache2-mod-php7.0 php7.0-cli php7.0-common php7.0-mbstring php7.0-gd php7.0-intl php7.0-xml php7.0-mysql php7.0-mcrypt php7.0-zip
#RUN yum install -y php php-mysql php-devel php-gd php-pecl-memcache php-pspell php-snmp php-xmlrpc php-xml

# install sshd
RUN apt-get install -y openssh-server openssh-client passwd
RUN mkdir -p /var/run/sshd

# install some helpful tools
RUN apt-get install -y drush

#RUN ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_dsa_key && ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key 
RUN sed -ri 's/PermitRootLogin without-password/PermitRootLogin yes/g' /etc/ssh/sshd_config
RUN echo 'root:changeme' | chpasswd

# Put your own public key at id_rsa.pub for key-based login.
RUN mkdir -p /root/.ssh && touch /root/.ssh/authorized_keys && chmod 700 /root/.ssh
#ADD id_rsa.pub /root/.ssh/authorized_keys

# Enable apache mods.
RUN a2enmod rewrite
RUN a2enmod headers
RUN a2enmod ssl

# Enable PHP mods.
#RUN php5enmod mcrypt
#RUN php5enmod curl

#ADD phpinfo.php /var/www/html/
#ADD supervisord.conf /etc/
EXPOSE 22 80 443

# Install Composer
RUN curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer
RUN composer install

RUN mkdir -p /etc/apache2/certs

ADD config/apache2.conf /etc/apache2
ADD config/default-site.conf /etc/apache2/sites-available

RUN touch /root/update-sites-from-config.sh; rm /root/update-sites-from-config.sh;
ADD scripts/update-sites-from-config.sh /root
RUN touch /root/update-sites.sh; rm /root/update-sites.sh;
ADD scripts/update-sites.sh /root
RUN touch /root/sites_config.yml; rm /root/sites_config.yml;
ADD sites_config.yml /root

RUN chmod +x /root/update-sites.sh
RUN chmod +x /root/update-sites-from-config.sh

CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
