#!/bin/bash

# fail if anything fails
set -e

source common.sh

DATA_DIR="/flow/data/testnet-33"

# bootstrap function should set those variables
GCP_BUCKET=""
SEED_ADDRESS=""
SEED_KEY=""

bootstrap "testnet" 33 "$DATA_DIR"

live_data "testnet-33"  "https://storage.googleapis.com/flow-genesis-bootstrap/devnet-33-execution" "f4f74ea6d7c31e5c77bfc41c019b196769b174514c9fc16c57a1c82ac424008e"

/usr/bin/supervisord -c /supervisord.conf