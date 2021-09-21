#!/bin/bash

# fail if anything fails
set -e

source common.sh

live_data "testnet-27"  "https://storage.googleapis.com/flow-genesis-bootstrap/devnet-27-execution" "676fe17738954c7602258696821d2a2ab24cc713f89a440c356523ebd8efca7f"

/usr/bin/supervisord -c /supervisord.conf