FROM ubuntu:16.04
LABEL maintainer="Devin Lumley <devin@highwaythreesolutions.com>"

# Setup environment
ENV DEBIAN_FRONTEND noninteractive

# Update sources
RUN apt-get update -y

# Install Apache and other tools
RUN apt-get install -y locales curl software-properties-common git \
	apt-utils vim unzip apache2 bash-completion openssh-server openssh-client passwd \
	&& locale-gen en_US.UTF-8
RUN mkdir -p /var/lock/apache2 /var/run/apache2

# Install PHP and modules
RUN LC_ALL=en_US.UTF-8 add-apt-repository ppa:ondrej/php && LC_ALL=en_US.UTF-8 add-apt-repository ppa:ondrej/apache2 && apt-get update
RUN apt-get install -y --force-yes php7.1-bcmath php7.1-bz2 php7.1-cli php7.1-common php7.1-curl \
                php7.1-cgi php7.1-dev php7.1-fpm php7.1-gd php7.1-gmp php7.1-imap php7.1-intl \
                php7.1-json php7.1-ldap php7.1-mbstring php7.1-mcrypt php7.1-mysql \
                php7.1-odbc php7.1-opcache php7.1-pgsql php7.1-phpdbg php7.1-pspell \
                php7.1-readline php7.1-recode php7.1-soap php7.1-sqlite3 \
                php7.1-tidy php7.1-xml php7.1-xmlrpc php7.1-xsl php7.1-zip \
                libapache2-mod-php7.1

# Install sshd
RUN apt-get install -y openssh-server openssh-client passwd
RUN mkdir -p /var/run/sshd

# Install composer and drush
RUN curl -sS http://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN apt-get install -y drush

# Set up root SSH access
RUN sed -ri 's/PermitRootLogin without-password/PermitRootLogin yes/g' /etc/ssh/sshd_config
RUN echo 'root:changeme' | chpasswd

# Put your own public key at id_rsa.pub for key-based login.
RUN mkdir -p /root/.ssh && touch /root/.ssh/authorized_keys && chmod 700 /root/.ssh
#ADD id_rsa.pub /root/.ssh/authorized_keys

# Enable apache mods
RUN a2enmod rewrite
RUN a2enmod headers
RUN a2enmod ssl

# Set up certs
RUN mkdir -p /etc/apache2/certs

# Copy over Apache config
ADD config/apache2.conf /etc/apache2
ADD config/default-site.conf /etc/apache2/sites-available

ADD scripts/update-sites-from-config.sh /usr/bin/update-sites-from-config
ADD scripts/update-sites.sh /usr/bin/update-sites
ADD scripts/run-in.sh /usr/bin/run-in
ADD config/*.yml /root

RUN chmod +x /usr/bin/run-in
RUN chmod +x /usr/bin/update-sites
RUN chmod +x /usr/bin/update-sites-from-config

EXPOSE 22 80 443

CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
