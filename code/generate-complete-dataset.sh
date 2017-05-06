#!/bin/bash
# A Bash script for generating all data required for the project in one script.
# Usage: ./generate-complete-dataset <state>

# Check for appropriate arguments
if [ "$#" -ne 1 ]; then
    echo "Usage: ./generate-complete-dataset <state>"
    exit 1
fi

# Get the state and set up directory for data
STATE=$1
mkdir ../data/$STATE
mkdir ../data/complete
REDIRECT=


echo 'Pulling data from open-states... (Running open-states.py)'
python open-states.py $STATE $REDIRECT
if [ $? -ne 0 ]; then
  echo 'ERROR: Failed to complete open-states.py'
fi

echo 'Creating parities and weights... (Running clean-state.R)'
Rscript clean-state.R "$STATE" "$PWD" $REDIRECT
if [ $? -ne 0 ]; then
  echo 'ERROR: Failed to complete clean-state.R'
fi

echo 'Merging parities and sentator info... (Running reshape.js)'
node reshape.js $STATE $REDIRECT
if [ $? -ne 0 ]; then
  echo 'ERROR: Failed to complete reshape.js'
fi

echo 'Merging weights and senator info... (Running makeJson.js)'
python makeJson.py $STATE $REDIRECT
if [ $? -ne 0 ]; then
  echo 'ERROR: Failed to complete makeJson.js'
fi

echo 'Completed'
