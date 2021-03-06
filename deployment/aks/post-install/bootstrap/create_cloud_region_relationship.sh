#!/bin/bash
# Copyright 2019 AT&T Intellectual Property. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -x 

if [ -z $AAI_DNS_NAME ] || [ -z $AAI_PORT ]; then
  echo "AAI_DNS_NAME or AAI_PORT not found. These should be environment variables."
  exit 1
fi

DATA_FILE=$BUILD_DIR"/aai_cloudregionrelationship.json"

URI="aai/v11/cloud-infrastructure/cloud-regions/cloud-region/$CLOUD_OWNER/$CLOUD_REGION/relationship-list/relationship"

cat > $DATA_FILE <<EOF
{
    "related-to": "complex",
    "related-link": "/aai/v11/cloud-infrastructure/complexes/complex/$CLLI",
    "relationship-data": [{
        "relationship-key": "complex.physical-location-id",
        "relationship-value": "$CLLI"
    }]
}
EOF

curl -i --insecure -u $AAI_USER:$AAI_PASS -X PUT "$AAI_PROTOCOL://$AAI_DNS_NAME:$AAI_PORT/$URI" \
  -H 'X-TransactionId: 9999' \
  -H 'X-FromAppId: jimmy-postman' \
  -H 'Real-Time: true' \
  -H 'Content-Type: application/json' \
  -H 'Accept: application/json' \
  -H 'Cache-Control: no-cache' \
  -d @"$DATA_FILE"
echo ""
