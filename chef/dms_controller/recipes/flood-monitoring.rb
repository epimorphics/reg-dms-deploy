# Cookbook Name:: dms_controller
# Recipe:: flood-monitoring
#
# Copyright (C) 2014 Epimorphics Ltd
#

include_recipe "ea-floods-updater"

# Install polygons to deployable web area

webdir='/var/opt/dms/services/floods/publicationSets/production/Web'
directory webdir do
    owner 'tomcat7'
    group 'tomcat7'
    mode 0755
    recursive true
end

directory "#{webdir}/flood-monitoring" do
    owner 'tomcat7'
    group 'tomcat7'
    mode 0755
    recursive true
end

img = 'flood_polygons.tgz'
bash "Fetch polygons" do
    code <<-EOH
    cd #{node['epi_base']['deploy_files_dir']}
    aws s3api get-object --bucket dms-deploy --key flood-monitoring/#{img} #{img}
    EOH
    not_if { File.exists?("#{node['epi_base']['deploy_files_dir']}/#{img}") }
end

bash "Install polygons" do
    code <<-EOH
    cd #{webdir}/flood-monitoring
    tar zxf #{node['epi_base']['deploy_files_dir']}/#{img}
    chown -R tomcat7:tomcat7 .
    EOH
    not_if { File.exists?("#{webdir}/flood-monitoring/flood_areas") }
end

# Daily cleanup support

cookbook_file "/var/opt/flood-monitoring/bin/dailyClean.sh" do
    source 'flood-dailyClean.sh'
    owner "tomcat7"
    group "tomcat7"
    mode  0744
end

cookbook_file "/var/opt/flood-monitoring/bin/periodicRebuild.sh" do
    source 'flood-periodicRebuild.sh'
    owner "ubuntu"
    group "ubuntu"
    mode  0755
end

cookbook_file "/var/opt/flood-monitoring/bin/installFloodAreas" do
    source 'flood-installFloodAreas'
    owner "ubuntu"
    group "ubuntu"
    mode  0755
end

file "/var/opt/flood-monitoring/logs/dailyClean.log" do
  owner 'tomcat7'
  group 'tomcat7'
  mode '0644'
  action :create
end

file "/var/opt/flood-monitoring/logs/dailyCleanCrontab.log" do
  owner 'tomcat7'
  group 'tomcat7'
  mode '0644'
  action :create
end

file "/var/opt/flood-monitoring/empty" do
  owner 'tomcat7'
  group 'tomcat7'
  mode '0644'
  action :create
end

cookbook_file "/var/opt/flood-monitoring/bin/archive.sh" do
    source 'flood-archive.sh'
    owner "ubuntu"
    group "ubuntu"
    mode  0744
end



# crontab entry which includes archive and daily/weekly clean as well
cookbook_file "/etc/cron.d/flood-monitoring" do
    source "flood-crontab"
    mode  0644
end
