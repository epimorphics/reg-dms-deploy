#!/bin/bash
# Script to provision nagios and nagrestconf on a configured DMS server
# Assumes the .deb images have been installed by the nagrestconf recipe

cd /home/ubuntu/deploy

# Install the packages
gdebi --non-interactive nagrestconf_1.173_all.deb
dpkg -i nagrestconf-services-plugin_1.173_all.deb \
      nagrestconf-services-bulktools-plugin_1.173_all.deb \
      nagrestconf-hosts-bulktools-plugin_1.173_all.deb \
      nagrestconf-backup-plugin_1.173_all.deb

# Wire up nagestconf default configuration
nagrestconf_install -a
slc_configure --folder=local

# Enable via virtual host includes instead
#ln -s /etc/apache2/conf.d/nagrestconf.conf /etc/apache2/conf-enabled/
#ln -s /etc/apache2/conf.d/rest.conf /etc/apache2/conf-enabled/

cat /var/spool/cron/root >>/var/spool/cron/crontabs/root
chmod 0600 /var/spool/cron/crontabs/root
service cron restart

sed -i 's/check_external_commands=0/check_external_commands=1/g' /etc/nagios3/nagios.cfg
sed -i 's/enable_embedded_perl=1/enable_embedded_perl=0/g' /etc/nagios3/nagios.cfg

chmod 770 /var/lib/nagios3/rw/

htpasswd -bc /etc/nagios3/nagrestconf.users nagrestconfadmin epinagrest

cp /etc/apache2/conf.d/nagrestconf.conf /tmp
sed -i 's#AuthUserFile .*#AuthUserFile /etc/nagios3/nagrestconf.users#i' /etc/apache2/conf.d/nagrestconf.conf
sed -i 's/allow from 127.0.0.1/allow from all/i' /etc/apache2/conf.d/nagrestconf.conf
sed -i 's/#Require/Require/i'     /etc/apache2/conf.d/nagrestconf.conf
sed -i 's/#Auth/Auth/i'     /etc/apache2/conf.d/nagrestconf.conf

service apache2 restart

# Add pre-canned configuration setup
cd /etc/nagios3/objects/local/setup
tar xzf /home/ubuntu/deploy/nrc_setup.tgz
curl --data 'json={"folder":"local"}' http://127.0.0.1/rest/apply/nagiosconfig

# get nagios to reconsult
service nagios3 restart

