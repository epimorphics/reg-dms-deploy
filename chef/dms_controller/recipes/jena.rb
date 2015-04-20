#
# Cookbook Name:: dms_controller
# Recipe:: jena
#
# Copyright (C) 2014 Epimorphics Ltd
#

# Package is out of date, do it manually
# package 'awscli'

jena_tar = "#{node['dms_controller']['jena_version']}.tar.gz"
jena_unpack = "#{node['epi_base']['deploy_files_dir']}/#{node['dms_controller']['jena_version']}"

remote_file 'jena' do
    path "#{node['epi_base']['deploy_files_dir']}/#{jena_tar}"
    source "http://mirror.ox.ac.uk/sites/rsync.apache.org/jena/binaries/#{jena_tar}"
    action :create_if_missing
end

bash "Unpack jena" do
    code <<-EOH
        cd #{node['epi_base']['deploy_files_dir']}
        tar xzf #{jena_tar}
        chmod a+r #{jena_unpack}/jena-log4j.properties
    EOH
    not_if { File.exists?(jena_unpack) }
end

link "/opt/jena" do
    to jena_unpack
end
