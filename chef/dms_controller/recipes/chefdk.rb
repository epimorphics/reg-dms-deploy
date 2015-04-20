#
# Cookbook Name:: dms_controller
# Recipe:: chefdk
#
# Copyright (C) 2014 Epimorphics Ltd
#

chefdk=node['dms_controller']['chefdk_version']
user=node['dms_controller']['user'] 

remote_file 'chefdk' do
    path "#{node['epi_base']['deploy_files_dir']}/#{chefdk}"
    source "https://opscode-omnibus-packages.s3.amazonaws.com/ubuntu/12.04/x86_64/#{chefdk}"
    action :create_if_missing
end

bash "Install chefdk and knife solo" do
    code <<-EOH
        PKG_OK=$(dpkg-query -W --showformat='${Status}\n' chefdk|grep "install ok installed")
        if [[ -z $PKG_OK ]]; then
            dpkg -i "#{node['epi_base']['deploy_files_dir']}/#{chefdk}"
            /opt/chefdk/embedded/bin/gem install knife-solo
        fi
    EOH
end

cookbook_file 'bashrc' do
    path "/home/#{user}/.bashrc"
    action :create
    owner user
    group user
    mode  0644
end

directory "/home/#{user}/.chef" do
    owner user
    group user
    mode  0755
end

cookbook_file 'knife.rb' do
    path "/home/#{user}/.chef/knife.rb"
    action :create
    owner user
    group user
    mode  0644
end

directory "/var/opt/dms/.chef" do
    owner 'tomcat7'
    group 'tomcat7'
    mode  0755
end

cookbook_file 'knife.rb' do
    path "/var/opt/dms/.chef/knife.rb"
    action :create
    owner 'tomcat7'
    group 'tomcat7'
    mode  0644
end

["epimorph-validator@epi-chef-server.pem", "epimorph@epi-chef-server.pem", "data_bag_key"].each do |key|
    bash "Install server access key #{key}" do
        code <<-EOH
            aws s3api get-object --bucket dms-deploy --key chef-keys/#{key} /home/#{user}/.chef/#{key}
            chown #{user}:#{user} /home/#{user}/.chef/#{key}
            chmod 0600 /home/#{user}/.chef/#{key}
            cp /home/#{user}/.chef/#{key} /var/opt/dms/.chef/#{key}
            chown tomcat7:tomcat7 /var/opt/dms/.chef/#{key}
            chmod 0600 /var/opt/dms/.chef/#{key}
        EOH
        not_if { File.exists?("/home/#{user}/.chef/#{key}") }
    end
end
