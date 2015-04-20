#
# Cookbook Name:: dms_controller
# Recipe:: diskconfig
#
# Copyright (C) 2014 Epimorphics Ltd
#

user=node['dms_controller']['user'] 

directory "/mnt/disk1/var/opt/dms" do
    owner 'tomcat7'
    group 'tomcat7'
    mode  0755    
    recursive true
end

link "/var/opt/dms" do
    to   "/mnt/disk1/var/opt/dms"
end

directory "/mnt/disk1/graphite" do
    mode  0755    
    recursive true
end

link "/var/lib/graphite" do
    to   "/mnt/disk1/graphite"
end

directory "/mnt/disk1/nagrestconf" do
    mode  0755    
    recursive true
end

directory "/etc/nagios3" do
    mode 0755
end

link "/etc/nagios3/objects" do
    to   "/mnt/disk1/nagrestconf"
end
