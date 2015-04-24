#
# Cookbook Name:: dms_controller
# Recipe:: default
#
# Copyright (C) 2014 Epimorphics Ltd
#
# All rights reserved - Do Not Redistribute
#

include_recipe "dms_controller_base"

include_recipe "dms_controller::grafana"

#  include_recipe "dms_controller::lds"
