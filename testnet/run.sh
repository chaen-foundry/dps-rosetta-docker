#!/bin/bash

# fail if anything fails
set -e

source common.sh

live_data "testnet-28"  "https://storage.googleapis.com/flow-genesis-bootstrap/devnet-28-execution" "f4f74ea6d7c31e5c77bfc41c019b196769b174514c9fc16c57a1c82ac424008e"

/usr/bin/supervisord -c /supervisord.conf