node.override['epi_tomcat']['java_options']       = '-Xmx800M -Djava.awt.headless=true'
node.override['dms_controller']['user']           = 'ubuntu'
node.override['dms_controller']['chefdk_version'] = 'chefdk_0.2.1-1_amd64.deb'
node.override['dms_controller']['dms_war_base']   = 's3://epi-private-repository/snapshot/com/epimorphics/dms-app/0.0.1-SNAPSHOT'
node.override['dms_controller']['dms_war']        = 'dms-app-0.0.1-20150412.101132-27.war'
node.override['dms_controller']['webapps']        = '/var/lib/tomcat7/webapps'
node.override['dms_controller']['jena_version']   = 'apache-jena-2.12.1'

node.override['dms_controller']['graphite_packages']   = '/usr/lib/python2.7/dist-packages/graphite'
node.override['dms_controller']['monitor_LBs']    = 'floods-producti-producti-LB bwq-testing-dataserv-LB bwq-testing-presServ-LB bwq-producti-dataserv-LB bwq-producti-presServ-LB'

#node.override['dms_controller']['testing_baseline_images'] = [ "baseline-2014-08-01.nq.gz", "baseline-2014-08-01.DB.tgz" ]
node.override['dms_controller']['testing_baseline_images'] = [ "baseline-2014-08-01-noprofile.nq.gz", "baseline-2014-08-01-noprofile.DB.tgz" ]
node.override['dms_controller']['testing_web_snapshot'] = 'web-media-2014-10-27.tgz'
node.override['dms_controller']['production_baseline_images'] = [ "baseline-2014-10-02-noprofile.nq.gz", "baseline-2014-10-02-noprofile.DB.tgz" ]
node.override['dms_controller']['production_web_snapshot'] = 'web-media-2014-10-27.tgz'
#node.override['dms_controller']['production_web_snapshot'] = 'web-media-2015-03-24.tgz'

node.override['dms_controller']['vpc_gateway']    = '10.0.1.1'
node.override['dms_controller']['monitor_ip']     = '10.0.1.8'

# node.override['ea-floods-master']['converter_jar']  = 's3://epi-private-repository/release/com/epimorphics/RTdata/0.0.1/RTdata-0.0.1-run.jar'
node.override['ea-floods-master']['worker_name']  = 'dms-controller'
