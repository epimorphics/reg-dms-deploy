#
# Cookbook Name:: dms_controller
# Recipe:: dms_conf
#
# Copyright (C) 2014 Epimorphics Ltd
#

deploy "#{node['epi_base']['deploy_files_dir']}/dms-conf" do
    repo "#{node['dms_controller']['conf_repo']}" 
if node['dms_controller']['conf_repo_is_private']
    ssh_wrapper "#{node['epi_base']['deploy_files_dir']}/wrap-ssh4git.sh" 
end
    symlink_before_migrate ({})
    symlinks ({})
    user user
    group user
end

#link "/opt/dms" do
#    to  "#{node['epi_base']['deploy_files_dir']}/dms-conf/current"
#end

# Copy rather than link config to avoid a bug with monitoring cascaded symlinks
directory "/opt/dms" do
    owner user
    group user
    mode  0755
    recursive true
end

bash "Copy configuration to /opt/dms" do
    code <<-EOH
        rm /opt/dms/*
        cp -r #{node['epi_base']['deploy_files_dir']}/dms-conf/current/runtime/* /opt/dms
        chown -R #{user}:#{user} /opt/dms/*
    EOH
end
