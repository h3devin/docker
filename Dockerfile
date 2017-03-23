FROM ubuntu:14.04
MAINTAINER Devin Lumley <devin@highwaythreesolutions.com>

# Setup environment
ENV DEBIAN_FRONTEND noninteractive

# Update sources
RUN apt-get update -y

# install http
RUN apt-get install -y apache2 vim bash-completion unzip
RUN mkdir -p /var/lock/apache2 /var/run/apache2

# install php
RUN apt-get install -y php5 php5-mysql php5-dev php5-gd php5-memcache php5-pspell php5-snmp snmp php5-xmlrpc libapache2-mod-php5 php5-cli php5-curl php5-mcrypt
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

#ADD phpinfo.php /var/www/html/
#ADD supervisord.conf /etc/
EXPOSE 22 80 443

ADD config/apache2.conf /etc/apache2
ADD config/default-site.conf /etc/apache2/sites-available

ADD scripts/update-sites.sh /root
RUN chmod +x /root/update-sites.sh

CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]