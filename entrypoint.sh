#!/bin/bash

# Exit script as soon as a command fails.
set -e 

echo "-----------------------------------------------------"
echo "STARTING FASTAPI ENTRYPOINT $(date)"
echo "-----------------------------------------------------"

cmd="$@"

# You can put other setup logic here

echo "-----------------------------------------------------"
echo "FINISHED FASTAPI ENTRYPOINT $(date)"
echo "-----------------------------------------------------"

# Run the CMD 
echo "got command $cmd"
exec "$cmd"