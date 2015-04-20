#
# Cookbook Name:: dms_controller
# Recipe:: graphana
#
# Copyright (C) 2014 Epimorphics Ltd
#

# pull credentials config from S3
bash "Install graphana from local copy" do
    code <<-EOH
        aws s3api get-object --bucket dms-deploy --key graphana/grafana-1.8.1.tar.gz #{node['epi_base']['deploy_files_dir']}/grafana.tgz
        cd #{node['epi_base']['deploy_files_dir']}
        tar xzf grafana.tgz
        mv grafana-1* grafana
        chown -R www-data:www-data grafana
    EOH
    not_if { File.exists?("#{node['epi_base']['deploy_files_dir']}/grafana.tgz") }
end

link "/usr/share/grafana" do
    to  "#{node['epi_base']['deploy_files_dir']}/grafana"
end

cookbook_file "/usr/share/grafana/config.js" do
    user 'www-data'
    group 'www-data'
    source "grafana-config.js"
end

['dms', 'floods-production', 'bwq-production', 'bwq-testing'].each do |dash|
    cookbook_file "/usr/share/grafana/app/dashboards/#{dash}.json" do
        user 'www-data'
        group 'www-data'
        source "grafana-dashboard-#{dash}.json"
    end
end

file "/usr/share/grafana/app/dashboards/default.json" do
    action :delete
end

link "/usr/share/grafana/app/dashboards/default.json" do
    to  "/usr/share/grafana/app/dashboards/dms.json"
end

cookbook_file "/etc/apache2/conf-available/grafana.conf" do
    source "grafana.conf"
    mode 0644
end

# Included via site configuration
#bash "Install grafana alias" do
#    code <<-EOH
#        a2enconf grafana
#    EOH
#    notifies :reload, "service[apache2]", :delayed
#end
