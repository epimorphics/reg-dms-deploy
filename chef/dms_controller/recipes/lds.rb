#
# Cookbook Name:: dms_controller
# Recipe:: lds
#
# Copyright (C) 2014 Epimorphics Ltd
#

# Starting data images
['testing', 'production'].each do |envname|
    directory "/var/opt/dms/services/bwq/publicationSets/#{envname}/images" do
        owner 'tomcat7'
        group 'tomcat7'
        mode 0755
        recursive true
    end

    node['dms_controller']["#{envname}_baseline_images"].each do |img|
        bash "Install baseline image #{img} to #{envname}" do
            code <<-EOH
            cd /var/opt/dms/services/bwq/publicationSets/#{envname}/images
            aws s3api get-object --bucket dms-deploy --key baseline/#{img} #{img}
            chown tomcat7:tomcat7  #{img}
            chmod 0644  #{img}
            EOH
            not_if { File.exists?("/var/opt/dms/services/bwq/publicationSets/#{envname}/images/#{img}") }
        end
    end
end


# Starting web content
['testing', 'production'].each do |envname|
    directory "/var/opt/dms/services/bwq/publicationSets/#{envname}/Web" do
        owner 'tomcat7'
        group 'tomcat7'
        mode 0755
        recursive true
    end

    img = node['dms_controller']["#{envname}_web_snapshot"]
    bash "Fetch web content for #{envname}" do
        code <<-EOH
        cd #{node['epi_base']['deploy_files_dir']}
        aws s3api get-object --bucket dms-deploy --key baseline/#{img} #{img}
        EOH
        not_if { File.exists?("#{node['epi_base']['deploy_files_dir']}/#{img}") }
    end

    bash "Install web content for #{envname}" do
        code <<-EOH
        cd /var/opt/dms/services/bwq/publicationSets/#{envname}/Web
        tar zxf #{node['epi_base']['deploy_files_dir']}/#{img}
        chown -R tomcat7:tomcat7 .
        EOH
        not_if { File.exists?("/var/opt/dms/services/bwq/publicationSets/#{envname}/Web/media") }
    end
end
