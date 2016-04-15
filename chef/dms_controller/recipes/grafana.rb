#
# Cookbook Name:: dms_controller
# Recipe:: graphana
#
# Copyright (C) 2014 Epimorphics Ltd
#

node['dms_controller']['grafana_dashboards'].each do |dash|
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
