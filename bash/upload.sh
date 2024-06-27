#!/bin/bash

# Define the URL
dataNetworkUrl="http://ipfs-dev.align.network/upload"
#dataNetworkUrl="http://ipfs.align.network/upload" # Prod
#dataNetworkUrl="http://localhost:4003/upload"

# Function to upload data
upload() {
  local data=$1
  # Make the POST request using curl
  response=$(curl -s -X POST "$dataNetworkUrl" \
    -H "Content-Type: application/json" \
    -d "$data")

  if [ $? -ne 0 ]; then
      echo "Error uploading data check network connection"
      exit 1
  fi
  echo $response
  name=$(echo "$data" | grep -o '"name": "[^"]*' | sed 's/"name": "//')
  cid_field=$(echo "$response" | grep -o '"cid":"[^"]*' | sed 's/"cid":"//' | sed 's/".*//')


  echo -e "$name - $cid_field"
}

alignnft1metadata='{
    "image": "https://ipfs.align.network/ipfs/bafyreig3mjzbip6vfmfutkdlhdssq6gjragatkjdb2zcf5an5pd3dmdiqu"
  }'
upload "$alignnft1metadata"