Deployment scripts for creating a DMS instance including the DMS controller and the monitoring components

## Deployment

Assumes awscli installed on your machine with a profile for where things should be created.

     export AWS_DEFAULT_PROFILE=control-lds 

     bin/createDMS     # Allocates server and initiates chef solo
     bin/configDMS     # Runs chef solo again if you need to reprovision of if first run fails
     bin/installNagios # Semi-interactive install actions
