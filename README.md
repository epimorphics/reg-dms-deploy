DMS configuration for Defra registry (and proxy?) management.

A customized instance of dms-deploy-base.

## Commands

All should be run from the root of the project directory tree

Command | Action
---|---
`bin/createDMS` | Allocates DMS controller server and initiates chef solo
`bin/installNagios` | Install nagios on DMS controller, semi-interactive so not part of chef solo, only needs to be run once
`bin/configDMS` | Update configuration of the DMS controller via chef solo
`bin/updateDMS` | Update the runtime configuration. Pulls configuration from git repo so changes must be committed and pushed to take effect
