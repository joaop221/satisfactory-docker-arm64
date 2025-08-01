#!/bin/bash

set -eux

echo "Check game status availability"
curl -k -f -s -S -X POST "https://127.0.0.1:${SERVERGAMEPORT-"7777"}/api/v1" \
    -H "Content-Type: application/json" \
    -d '{"function":"HealthCheck","data":{"clientCustomData":""}}' \
    | jq -e '.data.health == "healthy"'

