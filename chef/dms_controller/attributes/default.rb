# The prefix used to name this DMS instance
# Affects the naming of keys, S3 buckets, the control server
pre = 'reg'
node.override['dms_controller']['prefix']         = pre

# The DNS name to use for the control server
node.override['dms_controller']['server_name']    = "#{pre}-controller.epimorphics.net"

# Set to true to enable TLS connections for the control server
node.override['dms_controller']['use_https']      = true

# The git repository containing the service configuration, scripts and UI templates
node.override['dms_controller']['conf_repo']     = "https://github.com/epimorphics/#{pre}-dms-deploy.git"

# Space separated list of names of elastic load balancers that should be monitored 
# by vacuumetrix and fed in to grpahite/carbon store
# This information won't be known until after a service has been deployed
node.override['dms_controller']['monitor_LBs']    = ''

# The grafana dashboards to install, each name should correspond to a file "grafana-dashboard-{name}.json"
node.override['dms_controller']['grafana_dashboards'] = ['dms']
