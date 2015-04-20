current_dir = File.dirname(__FILE__)
log_level                :info
log_location             STDOUT
node_name                "epimorph"
client_key               "#{current_dir}/epimorph@epi-chef-server.pem"
validation_client_name   "epimorph-validator"
validation_key           "#{current_dir}/epimorph-validator@epi-chef-server.pem"
chef_server_url          "https://epi-chef-server.epimorphics.net"
cache_type               'BasicFile'
cache_options( :path => "#{ENV['HOME']}/.chef/checksums" )
knife[:secret_file] = "/var/opt/dms/.chef/data_bag_key"
