#
# Cookbook Name:: dms_controller
# Recipe:: netconfig
#
# Copyright (C) 2014 Epimorphics Ltd
#

# Set up a secondary network interface
# Used to enable instances to route metrics to DMS 

cookbook_file "/etc/iproute2/rt_tables" do
    source "rt_tables"
end

template "/etc/network/interfaces.d/eth1.cfg" do
    source "eth1.cfg"
end

bash "Enable secondary network interface" do
    code "ifup eth1"
end
