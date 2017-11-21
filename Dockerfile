FROM ubuntu:16.04
MAINTAINER Devin Lumley <devin@highwaythreesolutions.com>

# Setup environment
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get clean && apt-get -y update
RUN apt-get install -y locales curl software-properties-common git \
	apt-utils vim unzip apache2 bash-completion openssh-server openssh-client passwd drush \
	&& locale-gen en_US.UTF-8 

# Install php and apache2
RUN LC_ALL=en_US.UTF-8 add-apt-repository ppa:ondrej/php && LC_ALL=en_US.UTF-8 add-apt-repository ppa:ondrej/apache2 && apt-get update
RUN apt-get install -y --force-yes php7.1-bcmath php7.1-bz2 php7.1-cli php7.1-common php7.1-curl \
                php7.1-cgi php7.1-dev php7.1-fpm php7.1-gd php7.1-gmp php7.1-imap php7.1-intl \
                php7.1-json php7.1-ldap php7.1-mbstring php7.1-mcrypt php7.1-mysql \
                php7.1-odbc php7.1-opcache php7.1-pgsql php7.1-phpdbg php7.1-pspell \
                php7.1-readline php7.1-recode php7.1-soap php7.1-sqlite3 \
                php7.1-tidy php7.1-xml php7.1-xmlrpc php7.1-xsl php7.1-zip \
                libapache2-mod-php7.1

# Update sources
#RUN apt-get clean && apt-get -y update 

# Install sshd
RUN mkdir -p /var/run/sshd

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

EXPOSE 22 80 443

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN mkdir -p /etc/apache2/certs

ADD config/apache2.conf /etc/apache2
ADD config/default-site.conf /etc/apache2/sites-available

RUN touch /root/update-sites-from-config.sh; rm /root/update-sites-from-config.sh; \
 	touch /root/update-sites.sh; rm /root/update-sites.sh; \
 	touch /root/sites_config.yml; rm /root/sites_config.yml;

ADD scripts/update-sites-from-config.sh /root
ADD scripts/update-sites.sh /root
ADD sites_config.yml /root

RUN chmod +x /root/update-sites.sh
RUN chmod +x /root/update-sites-from-config.sh

CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
