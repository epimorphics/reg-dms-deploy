name             'dms_controller'
maintainer       'Epimorphics Ltd'
maintainer_email 'dave@epimorphics.com'
license          'All rights reserved'
description      'Installs/Configures dms_controller'
long_description 'Installs/Configures dms_controller'
version          '0.1.12'

depends "epi_base"
depends "epi_server_base", ">= 0.2.7"
depends "epi_java"
depends "epi_tomcat", ">= 0.1.2"
depends "epi_apache", ">= 0.4.1"
depends "epi_ruby"
depends "epi_collectd"
depends "ea-floods-updater"
