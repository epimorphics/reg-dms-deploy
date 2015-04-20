#
# Cookbook Name:: dms_controller
# Recipe:: vacuumetrix
#
# Copyright (C) 2014 Epimorphics Ltd
#

# Assumes ruby is installed from epi_ruby recipe or similar

package 'build-essential'
package 'libcurl3'
package 'libcurl3-gnutls'
package 'libcurl4-openssl-dev'

user=node['dms_controller']['user']

# gems
[  "json", "fog" ].each do |key|
    gem_package key do
        gem_binary("/usr/bin/gem")
        options("--no-ri --no-rdoc")
        action :install
    end
end

# Deploy the utility from github
deploy "#{node['epi_base']['deploy_files_dir']}/vacuumetrix" do
    repo "https://github.com/99designs/vacuumetrix.git"
    symlink_before_migrate ({})
    symlinks ({})
    user user
    group user
end

link "/opt/vacuumetrix" do
    to  "#{node['epi_base']['deploy_files_dir']}/vacuumetrix/current"
end

# Patch to primary script to do a tiled time window and pass in LBs more cleanly
cookbook_file "/opt/vacuumetrix/bin/AWScloudwatchELB.rb" do
    source "vacuumetrix-AWScloudwatchELB.rb"
    user user
    group user
    mode  0755
end

# Configuration which sets the ELBs to monitor
template "/opt/vacuumetrix/conf/config.rb" do
    source "vacuumetrix-config.rb.erb"
    user user
    group user
    mode  0644
end

# pull credentials config from S3
bash "Install credentials for metrics access" do
    code <<-EOH
        aws s3api get-object --bucket dms-deploy --key vacuumetrix/vacuumetrix-credential.rb /opt/vacuumetrix/conf/credential.rb
        chown #{user}:#{user} /opt/vacuumetrix/conf/credential.rb
    EOH
    not_if { File.exists?("/opt/vacuumetrix/conf/credential.rb") }
end

# crontab entry to run this every 5 mins
cookbook_file "/etc/cron.d/vacuumetrix" do
    source "vacuumetrix-crontab"
    mode  0644
end
