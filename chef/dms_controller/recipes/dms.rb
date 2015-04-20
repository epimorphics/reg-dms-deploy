#
# Cookbook Name:: dms_controller
# Recipe:: dms
#
# Copyright (C) 2014 Epimorphics Ltd
#

package 'git'

user         = node['dms_controller']['user'] 
dms_war_base = node['dms_controller']['dms_war_base']
dms_war      = node['dms_controller']['dms_war']
dms_war_file = "#{node['epi_base']['deploy_files_dir']}/#{dms_war}"

bash "Fetch and install DMS war" do
    code <<-EOH
        aws s3 cp #{dms_war_base}/#{dms_war} #{dms_war_file}
        rm -r #{node['dms_controller']['webapps']}/dms*
        cp #{dms_war_file} #{node['dms_controller']['webapps']}/dms.war
    EOH
    not_if { File.exists?(dms_war_file) && ! File.zero?(dms_war_file) }
    notifies :restart, "service[tomcat7]", :delayed
end

cookbook_file 'apache-config' do
    path "/etc/apache2/sites-available/dms.conf"
    owner 'root'
    group 'root'
    mode  0644
end

bash "enable apache front end" do
  user 'root'
  code <<-EOH
    a2enmod proxy
    a2enmod proxy_http
    a2enmod proxy_ajp
    a2enmod rewrite
    a2enmod ssl
    a2enmod cache    
    a2dissite 000-default
    a2ensite dms
  EOH
  notifies :reload, "service[apache2]", :delayed
end

# Override epi_tomcat configuration to enable ajp
cookbook_file 'server.xml' do
    path "/var/lib/tomcat7/conf/server.xml"
    owner "#{node['epi_tomcat']['user_name']}"
    group "#{node['epi_tomcat']['user_name']}"
    mode  0644
    notifies :restart, "service[tomcat7]", :delayed
end

directory "/var/opt/dms/.ssh" do
    owner 'tomcat7'
    group 'tomcat7'
    mode  0755
    recursive true
end

bash "Install LDS key" do
    code <<-EOH
        aws s3api get-object --bucket dms-deploy --key instance-keys/lds.pem /var/opt/dms/.ssh/lds.pem
        chown tomcat7:tomcat7 /var/opt/dms/.ssh/lds.pem
        chmod 0600 /var/opt/dms/.ssh/lds.pem
        cp /var/opt/dms/.ssh/lds.pem /var/opt/dms/.ssh/lds-user.pem
        chown #{user}:#{user} /var/opt/dms/.ssh/lds-user.pem
        chmod 0600 /var/opt/dms/.ssh/lds-user.pem
    EOH
    not_if { File.exists?("/var/opt/dms/.ssh/lds.pem") }
end

# This may no-longer be needed, supressed use of known hosts
directory "/usr/share/tomcat7/.ssh" do
    owner 'tomcat7'
    group 'tomcat7'
    mode  0755    
    recursive true
end


cookbook_file 'dms-action-logrotate' do
    path "/etc/logrotate.d/dms"
    owner "root"
    group "root"
    mode  0644
end

cookbook_file 'dms-backup' do
    path "/etc/cron.daily/dmsbackup"
    owner "root"
    group "root"
    mode  0700
end

directory "/var/opt/dms/log" do
    owner "tomcat7"
    group "tomcat7"
    mode 0755
    recursive true
end

link "/var/log/dms" do
    to "/var/opt/dms/log"
end

# Utilities
cookbook_file "/usr/local/bin/dms-job" do
    source 'dms-job'
    owner user
    group group
    mode  0755
end

# Restore general access because grafana is linked via home/deploy
bash "Limit access to home directory" do
    code "chmod 0755 /home/ubuntu"
end

# crontab entry which includes daily log sync
cookbook_file "/etc/cron.d/dms" do
    source "dms-crontab"
    mode  0644
end
