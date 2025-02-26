#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -o errexit
# Prevent errors in a pipeline from being masked.
set -o pipefail
# Treat unset variables as an error and exit immediately.
set -o nounset

echo "-----------------------------------------------------"
echo "STARTING FASTAPI ENTRYPOINT $(date)"
echo "-----------------------------------------------------"

cmd="$@"

# You can put other setup logic here

echo "-----------------------------------------------------"
echo "FINISHED FASTAPI ENTRYPOINT"
echo "-----------------------------------------------------"

# Run the CMD 
echo "got command $cmd"
exec $cmd