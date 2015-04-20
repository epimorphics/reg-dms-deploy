#!/bin/bash
# Script to perform daily cleanup on database, run early in the morning after full day of data is in
set -o errexit

readonly BASE_DIR=/var/opt/flood-monitoring
readonly LOG="$BASE_DIR/logs/dailyClean.log"
readonly BASE_ENV=/var/opt/dms/services/floods/publicationSets/production
readonly TIER="$BASE_ENV/tiers/productionServers"
readonly SERVERS="$TIER/servers"
readonly DUMP_DIR="$BASE_ENV/Web/flood-monitoring/dumps"
readonly DEFAULT_SERVER_DIR="$SERVERS/s3"
readonly SERVICE="http://environment.data.gov.uk/flood-monitoring"
readonly DEFAULT_SERVER=$( jq -r .address "$DEFAULT_SERVER_DIR/config.json" )

readonly YESTERDAY=$(date +%F -d "-1 days")
readonly FOUR_WEEKS_AGO=$(date +%F -d "-28 days")
readonly NOW=$(date +%F/%H-%M-%S-%N)

readonly TOPIC_ARN=arn:aws:sns:eu-west-1:853478862498:Nagios-alerts
export AWS_DEFAULT_REGION=eu-west-1

. /opt/dms/conf/scripts/automation_lib.sh

report_error() {
    aws sns publish --topic-arn $TOPIC_ARN --subject "DMS Flood dailyClean failure" --message "Check /var/opt/flood-monitoring/logs/dailyClean.log" > /dev/null
}
trap report_error ERR

# Generate short and long form dump files for a given date
#     create_dump date
create_dump() {
    [[ $# = 1 ]] || { echo "Internal error calling create_dump" 1>&2 ; exit 99 ; }
    local dump_date="$1"
    mkdir -p $DUMP_DIR
    echo "$(date +%FT%T) Creating archive dump for $dump_date"
    curl -s "$SERVICE/data/readings.csv?date=$dump_date&_view=full" | gzip -c > $DUMP_DIR/readings-full-$dump_date.csv.gz
    curl -s "$SERVICE/data/readings.csv?date=$dump_date" | gzip -c > $DUMP_DIR/readings-$dump_date.csv.gz
}

# Publish drop-graph requests for all graphs on or before the given date
#     create_cleanup_script date
drop_old_graphs() {
    [[ $# = 1 ]] || { echo "Internal error calling drop_old_graphs" 1>&2 ; exit 99 ; }
    local cutoff_date="$1"
    /opt/jena/bin/rsparql --results JSON --service http://$DEFAULT_SERVER:3030/ds/query "
        PREFIX xsd:   <http://www.w3.org/2001/XMLSchema#> 
        SELECT DISTINCT ?x WHERE {
            GRAPH ?g {}
            BIND ( replace(str(?g), 'http://environment.data.gov.uk/flood-monitoring/graph/readings-', '') AS ?x )
            FILTER (xsd:date(?x) <= '$cutoff_date'^^xsd:date)
        }" \
    | jq -r ".results.bindings[].x.value" \
    | xargs -I {} aws s3 cp $BASE_DIR/empty s3://dms-deploy/images/flood-monitoring/updates/$NOW/cleanup_drop_http:%2F%2Fenvironment%2Edata%2Egov%2Euk%2Fflood-monitoring%2Fgraph%2Freadings-{}
}

# Delete all S3 telemetry update records whose name-as-date is more than AGE days old
# Usage: deleteOldS3UpdateRecords s3Base age
deleteOldS3UpdateRecords() {
    [[ $# = 2 ]] || { echo "Internal error calling deleteOldS3Records" 1>&2 ; exit 1 ; }
    local s3folder="$1"
    local age="$2"
    local cutoff=$(date +%F -d "-$age days")
    aws s3 ls "$s3folder/" \
    | awk '{x = $2; sub(/\//,"",x); print x;}' \
    | awk '$1 < "'$cutoff'" {print $1}' \
    | xargs -I {} aws s3 rm "$s3folder/{}" --recursive --exclude '*' --include '*/readings_update.ru.gz'
}

(
    echo "** Starting daily clean up $(date +%FT%T)"
    create_dump $YESTERDAY

    echo "$(date +%FT%T) Dropping old graphs:"
    drop_old_graphs $FOUR_WEEKS_AGO
    cd /opt/dms/conf/scripts
    dbutil/tierCatchupState.sh $TIER

    ## Distribute the dumps to the servers
#    floods/post-publish.sh services/floods/publicationSets/testing/tiers/testingServers
    floods/post-publish.sh services/floods/publicationSets/production/tiers/productionServers

    ## Clean up yesterday's now superseded one-off graphs (alerts and forecasts)
    aws s3 rm --recursive s3://dms-deploy/images/flood-monitoring/updates/$YESTERDAY --exclude '*' --include '*.ttl'

    echo "Creating backup image"
#    backupTier /var/opt/dms/services/floods/publicationSets/testing/tiers/testingServers s3://dms-deploy/images/flood-monitoring
    backupTier $TIER s3://dms-deploy/images/flood-monitoring

    echo "Delete old images and updates"
    deleteOldS3Records s3://dms-deploy/images/flood-monitoring/images 200
    deleteOldS3UpdateRecords s3://dms-deploy/images/flood-monitoring/updates 60

    echo "$(date +%FT%T) Completed"
) &>> $LOG

