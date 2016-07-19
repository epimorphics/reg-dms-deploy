#
# Cookbook Name:: dms_controller
# Recipe:: ssl
#
# Copyright (C) 2014 Epimorphics Ltd
#

# Install and renew letsencrypt certificate

cert_dir="/home/#{node.epi_base.deploy_user_name}/certificates"

directory cert_dir do
    owner 'root'
    group 'root'
    mode  0755
    recursive true
end

domain=node.dms_controller.server_name

epi_base_certificate "#{domain}" do
  path          cert_dir
  domains       [ "#{node.dms_controller.server_name}" ]
  email         'dave@epimorphics.com'
  test          false
end

link "/etc/ssl/private/#{domain}.key" do
    to "#{cert_dir}/#{domain}-key"
end

link "/etc/ssl/certs/IntermediateCA.crt" do
    to "#{cert_dir}/#{domain}-chain"
end

link "/etc/ssl/certs/ssl_certificate.crt" do
    to "#{cert_dir}/#{domain}-cert"
end
