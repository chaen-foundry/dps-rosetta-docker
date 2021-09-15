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

  ROOT_CHECKPOINT_DOWNLOAD_URL="$DOWNLOAD_BASE_URL/root.checkpoint"
  NODE_INFOS_DOWNLOAD_URL="$DOWNLOAD_BASE_URL/public-root-information/node-infos.pub.json"
  ROOT_PROTOCOL_STATE_SNAPSHOT_DOWNLOAD_URL="$DOWNLOAD_BASE_URL/public-root-information/root-protocol-state-snapshot.json"

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