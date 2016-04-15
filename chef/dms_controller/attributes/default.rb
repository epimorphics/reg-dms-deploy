# The prefix used to name this DMS instance
# Affects the naming of keys, S3 buckets, the control server
pre = 'nrw'
node.override['dms_controller']['prefix']         = pre

# The DNS name to use for the control server
node.override['dms_controller']['server_name']    = "#{pre}-controller.epimorphics.net"

# Set to true to enable TLS connections for the control server
node.override['dms_controller']['use_https']      = false

# The git repository containing the service configuration, scripts and UI templates
node.override['dms_controller']['conf_repo']     = "https://github.com/epimorphics/#{pre}-dms-deploy.git"

# Space separated list of names of elastic load balancers that should be monitored 
# by vacuumetrix and fed in to grpahite/carbon store
# This information won't be known until after a service has been deployed
node.override['dms_controller']['monitor_LBs']    = ''

# Baseline data and media
node.override['dms_controller']['baseline']['nrwbwq']['testing_baseline_images']    = [  ]
node.override['dms_controller']['baseline']['nrwbwq']['testing_web_snapshot']       = ''
node.override['dms_controller']['baseline']['nrwbwq']['production_baseline_images'] = [ ]
node.override['dms_controller']['baseline']['nrwbwq']['production_web_snapshot']    = ''
