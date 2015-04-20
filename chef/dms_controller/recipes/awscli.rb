#
# Cookbook Name:: dms_controller
# Recipe:: awscli
#
# Copyright (C) 2014 Epimorphics Ltd
#

# Package is out of date, do it manually
# package 'awscli'

package 'unzip'

remote_file 'awscli' do
    path "#{node['epi_base']['deploy_files_dir']}/awscli-bundle.zip"
    source "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip"
    action :create_if_missing
end

bash "Install awscli" do
    code <<-EOH
        cd #{node['epi_base']['deploy_files_dir']}
        unzip -o awscli-bundle.zip
        ./awscli-bundle/install -i /usr/local/aws -b /usr/bin/aws
    EOH
    not_if { File.exists?("/usr/bin/aws") }
end

user=node['dms_controller']['user'] 

directory "/home/#{user}/.aws" do
    owner user
    group user
    mode  0755
end

cookbook_file 'aws-config' do
    path "/home/#{user}/.aws/config"
    action :create_if_missing
    owner user
    group user
    mode  0644
end

remote_file 'jq' do
    path "/usr/bin/jq"
    source "http://stedolan.github.io/jq/download/linux64/jq"
    action :create_if_missing
    mode 0755
end
