#!/bin/bash

set -e
PROJECT=laravel-prod-image
CIRCLE_CI_API_KEY=
curl -X POST https://circleci.com/api/v1/project/**/${PROJECT}/tree/master?circle-token=${CIRCLE_CI_API_KEY}
echo "done circle.sh"