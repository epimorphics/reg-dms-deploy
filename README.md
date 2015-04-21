Deployment scripts for creating a DMS instance including the DMS controller and the monitoring components

For each copy of DMS create a repository with a copy of this (retain this as an upstream for bug fixes).

## AWS set up and configuration

See https://github.com/epimorphics/internal/wiki/Ops-install-new-DMS-instance

## Commands

All should be run from the root of the project directory tree

Command | Action
---|---
`bin/createDMS` | Allocates DMS controller server and initiates chef solo
`bin/installNagios` | Install nagios on DMS controller, semi-interactive so not part of chef solo, only needs to be run once
`bin/configDMS` | Update configuration of the DMS controller via chef solo
`bin/updateDMS` | Update the runtime configuration. Pulls configuration from git repo so changes must be committed and pushed to take effect
