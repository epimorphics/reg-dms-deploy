#
# Cookbook Name:: dms_controller
# Recipe:: nagrestconf
#
# Copyright (C) 2014 Epimorphics Ltd
#

##### This is just an initial test - not suitable for use ######

package 'gdebi-core'

[   "nagrestconf_1.173_all.deb", 
    "nagrestconf-services-plugin_1.173_all.deb",
    "nagrestconf-backup-plugin_1.173_all.deb",
    "nagrestconf-hosts-bulktools-plugin_1.173_all.deb",
    "nagrestconf-services-bulktools-plugin_1.173_all.deb"
].each do |key|
    remote_file  "#{node['epi_base']['deploy_files_dir']}/#{key}" do
        source "http://sourceforge.net/projects/nagrestconf/files/Ubuntu/#{key}/download"
        action :create_if_missing
    end
end

deploy=node['epi_base']['deploy_files_dir']

bash "Copy saved NRC configuration state to deploy area" do
    code <<-EOH
        aws sc cp s3://dms-deploy/nagrestconf/nrc_setup.tgz #{deploy}/nrc_setup.tgz
    EOH
    not_if { File.exists?("#{deploy}/nrc_setup.tgz") }
end

# Have to install by manual script, not easily chef-able
=begin
bash "Install nagrestconf" do
    code <<-EOH
        gdebi --non-interactive #{node['epi_base']['deploy_files_dir']}/nagrestconf_1.173_all.deb
    EOH
end
=end

cookbook_file 'apache-localhost.conf' do
    path "/etc/apache2/sites-available/localhost.conf"
    owner 'root'
    group 'root'
    mode  0644
end

bash "enable apache front end" do
  user 'root'
  code <<-EOH
    a2ensite localhost
  EOH
  notifies :reload, "service[apache2]", :delayed
end