#!/bin/bash

# Exit script in case of error
set -e

echo $"\n\n\n"
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