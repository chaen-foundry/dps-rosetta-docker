#!/bin/bash

# fail if anything fails
set -e

DATA_DIR="/data"

function past_data() {

  NETWORK_NAME=$1
  DOWNLOAD_URL=$2
  EXPECTED_SHA256=$3

  NETWORK_DIR="$DATA_DIR/$NETWORK_NAME"
  INDEX_DIR="$NETWORK_DIR/index"

  echo "Checking $NETWORK_NAME data"
  if [ ! -d "$NETWORK_DIR" ]; then
    TMP_FILE=$(mktemp -p "$DATA_DIR")
    wget -nv "$DOWNLOAD_URL" -O "$TMP_FILE"
    DOWNLOADED_SHA256=$(sha256sum "$TMP_FILE" | cut -d' ' -f1)

    if [ "$DOWNLOADED_SHA256" != "$EXPECTED_SHA256" ]; then
      echo "$NETWORK_NAME downloaded index checksum differs"
      exit 1
    fi

    mkdir -p "$NETWORK_DIR"

    /bin/restore-index-snapshot -c gzip -i "$INDEX_DIR" < "$TMP_FILE"
    echo "$NETWORK_NAME data restored"

    rm "$TMP_FILE"
  else
    echo "$NETWORK_NAME data already exists"
  fi
}

function live_data() {

  NETWORK_NAME=$1
  DOWNLOAD_BASE_URL=$2 #Make sure it doesn't end with /
  ROOT_CHECKPOINT_EXPECTED_SHA256=$3

  NETWORK_DIR="$DATA_DIR/$NETWORK_NAME"
  ROOT_CHECKPOINT_FILE="$NETWORK_DIR/root.checkpoint"
  PUBLIC_ROOT_INFO_DIR="$NETWORK_DIR/bootstrap/public-root-information"
  NODE_INFOS_FILE="$PUBLIC_ROOT_INFO_DIR/node-infos.pub.json"
  ROOT_PROTOCOL_STATE_SNAPSHOT_FILE="$PUBLIC_ROOT_INFO_DIR/root-protocol-state-snapshot.json"

  DOWNLOAD_BASE_URL="$DOWNLOAD_BASE_URL/public-root-information"
  ROOT_CHECKPOINT_DOWNLOAD_URL="$DOWNLOAD_BASE_URL/root.checkpoint"
  NODE_INFOS_DOWNLOAD_URL="$DOWNLOAD_BASE_URL/node-infos.pub.json"
  ROOT_PROTOCOL_STATE_SNAPSHOT_DOWNLOAD_URL="$DOWNLOAD_BASE_URL/root-protocol-state-snapshot.json"

  echo "Checking Live $NETWORK_NAME data"

  if [ ! -d "$NETWORK_DIR" ]; then
      TMP_FILE=$(mktemp -p "$DATA_DIR")
      wget -nv "$ROOT_CHECKPOINT_DOWNLOAD_URL" -O "$TMP_FILE"
      DOWNLOADED_SHA256=$(sha256sum "$TMP_FILE" | cut -d' ' -f1)

      if [ "$DOWNLOADED_SHA256" != "$ROOT_CHECKPOINT_EXPECTED_SHA256" ]; then
        echo "Live $NETWORK_NAME downloaded root.checkpoint checksum differs"
        exit 1
      fi

      mkdir "$NETWORK_DIR"

      mv "$TMP_FILE" "$ROOT_CHECKPOINT_FILE"

      # public root info
      mkdir -p "$PUBLIC_ROOT_INFO_DIR"

      wget -nv "$NODE_INFOS_DOWNLOAD_URL" -O "$NODE_INFOS_FILE"
      wget -nv "$ROOT_PROTOCOL_STATE_SNAPSHOT_DOWNLOAD_URL" -O "$ROOT_PROTOCOL_STATE_SNAPSHOT_FILE"

      echo "Live $NETWORK_NAME bootstrap data downloaded"

    else
      echo "Live $NETWORK_NAME bootstrap data already exists"
    fi

}

SPORKS_JSON="https://raw.githubusercontent.com/onflow/flow/master/sporks.json"

function bootstrap() {
  NETWORK_TYPE=$1
  NETWORK_NUMBER=$2
  DIR=$3

  BOOTSTRAP_DIR="$DIR/bootstrap"
  mkdir -p "$BOOTSTRAP_DIR"

  PUBLIC_ROOT_INFO_DIR="$BOOTSTRAP_DIR/public-root-information"
  mkdir -p "$PUBLIC_ROOT_INFO_DIR"

  SPORK_DATA=$(curl -s $SPORKS_JSON | jq .networks."$NETWORK_TYPE"."$NETWORK_TYPE""$NETWORK_NUMBER")

  ROOT_CHECKPOINT_URL=$(jq -r .stateArtefacts.gcp.rootCheckpointFile <<< "$SPORK_DATA")
  ROOT_PROTOCOL_STATE_SNAPSHOT_URL=$(jq -r .stateArtefacts.gcp.rootProtocolStateSnapshot <<< "$SPORK_DATA")

  ROOT_CHECKPOINT_FILE="$BOOTSTRAP_DIR/root.checkpoint"
  ROOT_PROTOCOL_STATE_SNAPSHOT_FILE="$PUBLIC_ROOT_INFO_DIR/root-protocol-state-snapshot.json"

  if [ ! -f "$ROOT_CHECKPOINT_FILE" ]; then
    curl -o "$ROOT_CHECKPOINT_FILE" $ROOT_CHECKPOINT_URL
  fi

  if [ ! -f "$ROOT_PROTOCOL_STATE_SNAPSHOT_FILE" ]; then
    curl -o "$ROOT_PROTOCOL_STATE_SNAPSHOT_FILE" "$ROOT_PROTOCOL_STATE_SNAPSHOT_URL"
  fi

  GCP_BUCKET=$(jq .stateArtefacts.gcp.executionStateBucket <<< "$SPORK_DATA")

  # this selects random node from the list
  SEED_NODES_COUNT=$(jq -r .seedNodes\|length <<< "$SPORK_DATA")
  # shellcheck disable=SC2004
  SELECTED_NODE=$(($RANDOM%SEED_NODES_COUNT))

  SEED_ADDRESS=$(jq -r .seedNodes[$SELECTED_NODE].address <<< "$SPORK_DATA")
  SEED_KEY=$(jq -r .seedNodes[$SELECTED_NODE].key <<< "$SPORK_DATA")
}