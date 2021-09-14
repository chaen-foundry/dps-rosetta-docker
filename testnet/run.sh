#!/bin/bash

# fail if anything fails
set -e

source common.sh

live_data "testnet-27"  "https://storage.googleapis.com/flow-genesis-bootstrap/testnet-27" "TBD"

/usr/bin/supervisord -c /supervisord.conf