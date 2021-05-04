#!/bin/bash
set -euo pipefail

M3U8_FILE_URL="$1"
NAME="$2"

# Setup
TMP_DIR=$(mktemp -d)
pushd $TMP_DIR

# Get base url
PROTO=$(echo $M3U8_FILE_URL | cut -d ":" -f1)
HOST=$(echo $M3U8_FILE_URL | cut -d "/" -f3)
BASE_URL="$PROTO://$HOST"

# Status
echo "M3U8: $M3U8_FILE_URL"
echo "BASE: $BASE_URL"

# Download the playlist
wget $M3U8_FILE_URL -O playlist.m3u8 > /dev/null 2>&1

# Download the .ts files
for TS in $(cat playlist.m3u8 | grep -E ".ts$"); do
  wget ${BASE_URL}${TS} > /dev/null 2>&1
  echo "DWNLD: ${TS}"
done

# Concat and transcode
echo "CONCAT: all.ts"
cat $(ls -1 seg-* | sort -V) > all.ts
echo "TRANSCODE: all.mp4"
ffmpeg -i all.ts -acodec copy -vcodec copy all.mp4 > /dev/null

# Cleanup
popd
cp $TMP_DIR/all.mp4 "$NAME.mp4"
echo "COPY: $NAME.mp4"
rm -fR $TMP_DIR
