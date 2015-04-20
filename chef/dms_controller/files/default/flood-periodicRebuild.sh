#!/bin/bash
# Queue automation worker to rebuild the databases on the production tier
S3STATE="s3://dms-deploy/images/flood-monitoring"
TIER="/var/opt/dms/services/floods/publicationSets/production/tiers/productionServers"
/usr/local/bin/dms-job rebuildDataTier "$TIER" "$S3STATE"
