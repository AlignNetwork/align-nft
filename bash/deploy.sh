#!/bin/bash

deploy_mainnet() {
    local script_name=$1
    echo "Deploying $script_name... to mainnet"
    source .env.prod && forge script script/$script_name:Deploy --sender $ALIGNPRODUSER --account ALIGNPRODUSER --fork-url $RPC_URL --broadcast -vvv --via-ir --verify
    
    echo "Deployed $script_name to mainnet!"
}

deploy_testnet() {
    local script_name=$1
    echo "Deploying $script_name... to testnet"
    source .env && forge script script/$script_name:Deploy  --sender $ALIGNPRODUSER --account ALIGNPRODUSER --fork-url $RPC_URL --broadcast -vvv --via-ir 
    
    echo "Deployed $script_name to testnet!"
}

mint_testnet() {
    local script_name=$1
    echo "Deploying $script_name... to testnet"
    source .env && forge script script/$script_name:Deploy  --sender $ALIGNPRODUSER --account ALIGNPRODUSER --fork-url $RPC_URL --broadcast -vvv --via-ir 
    
    echo "Deployed $script_name to testnet!"
}

deploy_script() {
    local script_name=$1
    local network=$2
    if [ "$network" == "mainnet" ]; then
        deploy_mainnet $script_name
    else
        deploy_testnet $script_name
    fi
}

# Check for command line argument
script=$1
network=$2

case $script in
  Deploy)
    deploy_script "Deploy.s.sol" $network
    ;;
  Mint)
    mint_testnet "Mint.s.sol" $network
    ;;
  UpdateBaseURI)
    deploy_script "UpdateBaseURI.s.sol" $network
    ;;
  *)
    echo "Invalid script name"
    exit 1
    ;;
esac