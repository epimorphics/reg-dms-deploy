#
# Cookbook Name:: dms_controller
# Recipe:: default
#
# Copyright (C) 2014 Epimorphics Ltd
#
# All rights reserved - Do Not Redistribute
#

include_recipe "dms_controller::netconfig"

include_recipe "epi_server_base"

include_recipe "epi_java"
include_recipe "epi_apache"

# Needs to be installed here so the other scripts can see the tomcat user
include_recipe "epi_tomcat"

include_recipe "dms_controller::diskconfig"

include_recipe "dms_controller::awscli"
include_recipe "dms_controller::chefdk"
include_recipe "dms_controller::jena"
include_recipe "dms_controller::dms"
include_recipe "dms_controller::dms_conf"

include_recipe "dms_controller::nagrestconf"
include_recipe "dms_controller::graphite"

include_recipe "epi_ruby"
include_recipe "dms_controller::vacuumetrix"
include_recipe "dms_controller::graphana"

include_recipe "dms_controller::lds"
include_recipe "epi_collectd"

include_recipe "dms_controller::flood-monitoring"
