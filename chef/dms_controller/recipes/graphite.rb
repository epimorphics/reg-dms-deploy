#
# Cookbook Name:: dms_controller
# Recipe:: graphite
#
# Copyright (C) 2014 Epimorphics Ltd
#

# Based on advice from:
# https://www.digitalocean.com/community/tutorials/how-to-install-and-use-graphite-on-an-ubuntu-14-04-server

package 'graphite-web'
package 'graphite-carbon'
package 'postgresql'
package 'libpq-dev'
package 'python-psycopg2'

deploy=node['epi_base']['deploy_files_dir']

cookbook_file "/etc/graphite/local_settings.py" do
    source "local_settings.py"
    owner 'root'
    group 'root'
    mode  0644
end

cookbook_file "#{deploy}/graphite-db.json" do
    source "graphite-db.json"
end

bash "Create postgres account" do
    cwd "#{deploy}"
    code <<-EOH
        sudo -u postgres psql -c "CREATE USER graphite WITH PASSWORD 'epigraphite';"
        sudo -u postgres psql -c "CREATE DATABASE graphite WITH OWNER graphite;"
        touch postgres.initialized
    EOH
    not_if { File.exists?("#{deploy}/postgres.initialized") }
end

bash "Intialize database tables for graphite" do
    cwd "#{node['dms_controller']['graphite_packages']}"
    code <<-EOH
        python manage.py syncdb --noinput
        python manage.py loaddata #{deploy}/graphite-db.json
        touch graphite-db.initialized
    EOH
    not_if { File.exists?("#{deploy}/graphite-db.initialized") }
end

cookbook_file "/etc/default/graphite-carbon" do
    source 'graphite-carbon'
    owner 'root'
    group 'root'
    mode  0644
end

cookbook_file "/etc/carbon/carbon.conf" do
    source 'carbon.conf'
    owner 'root'
    group 'root'
    mode  0644
end

cookbook_file "/etc/carbon/storage-aggregation.conf" do
    source 'storage-aggregation.conf'
    owner 'root'
    group 'root'
    mode  0644
end

cookbook_file "/etc/carbon/storage-schemas.conf" do
    source 'storage-schemas.conf'
    owner 'root'
    group 'root'
    mode  0644
end

service "carbon-cache" do
    action :start
end

package 'libapache2-mod-wsgi'

# Obsolete, graphite now installed underneath main site so it falls under SSL

#cookbook_file 'apache2-graphite.conf' do
#    path "/etc/apache2/sites-available/000-graphite.conf"
#    owner 'root'
#    group 'root'
#    mode  0644
#end

#bash "enable apache front end" do
#  user 'root'
#  code <<-EOH
#    a2ensite 000-graphite
#  EOH
#  notifies :reload, "service[apache2]", :delayed
#end
