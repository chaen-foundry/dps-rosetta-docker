#!/bin/bash

# fail if anything fails
set -e

source common.sh

#past_data "mainnet-3" "https://storage.googleapis.com/flow-genesis-bootstrap/dps/mainnet3-snapshot.gz" "d888cefcf1d390742c38be0efdfdcdbe4feb13c5900ed9463a0dc954078ff19d"
#past_data "mainnet-4" "https://storage.googleapis.com/flow-genesis-bootstrap/dps/mainnet4-snapshot.gz" "c578baad49dd8058eac38dcdcc858d1e15fb9dd21af655366f8679ef5dc6f84d"
#past_data "mainnet-5" "https://storage.googleapis.com/flow-genesis-bootstrap/dps/mainnet5-snapshot.gz" "2f20659821264ca0b05a608b48c1118e06bc2de3a87bc707a1295580e2bf34b5"
#past_data "mainnet-6" "https://storage.googleapis.com/flow-genesis-bootstrap/dps/mainnet6-snapshot.gz" "198a38ca393e7feb7bd66a9dc23579e6c0ebd6470a76c3bfc32e13b3e64ab690"
#past_data "mainnet-7" "https://storage.googleapis.com/flow-genesis-bootstrap/dps/mainnet7-snapshot.gz" "71df712108ca37cc03bfd7bb082195d445d13b45c3cb936778776683617b10cf"

#live_data "mainnet-13"  "https://storage.googleapis.com/flow-genesis-bootstrap/mainnet-13-execution" "17f925739cb914036144555499dd98e2dfac787e3ab01711304ab5e459aed825"
live_data "mainnet-14"  "https://storage.googleapis.com/flow-genesis-bootstrap/mainnet-14-execution" "17f925739cb914036144555499dd98e2dfac787e3ab01711304ab5e459aed825"


/usr/bin/supervisord -c /supervisord.conf