#!/bin/bash
# Script to peridocally archive the raw telemetry data

readonly BASE_DIR=/var/opt/flood-monitoring
cp "$BASE_DIR/incoming/telemetry.zip" "$BASE_DIR/archive/telemetry$(date +"%Y-%m-%dT%H-%M-%S").zip"
