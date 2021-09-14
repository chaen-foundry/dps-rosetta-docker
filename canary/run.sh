#!/bin/bash

# fail if anything fails
set -e

source common.sh

live_data "canary-8v2"  "https://storage.googleapis.com/flow-genesis-bootstrap/canary-8v2" "1158db830b9addbc55c4e5248e427fca7e06ffb05714276fe6f8fe97e747b226"

/usr/bin/supervisord -c /supervisord.conf