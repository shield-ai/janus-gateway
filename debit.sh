#!/bin/bash

VERSION="0.0.1"
TARGET_DIR="/opt/janus"

# Clean up
make clean

# Check pre-requisites
sudo apt install libmicrohttpd-dev libjansson-dev libnice-dev \
  libssl-dev libsrtp-dev libsofia-sip-ua-dev libglib2.0-dev \
  libopus-dev libogg-dev libini-config-dev libcollection-dev \
  pkg-config gengetopt libtool automake dh-autoreconf libwebsockets-dev

# Configure janus-gateway
sh autogen.sh
./configure --disable-data-channels --disable-rabbitmq --disable-mqtt --prefix=$TARGET_DIR

# Build
make
sudo make install

# Move configs
sudo cp -r ./shieldconfigs/* "$TARGET_DIR/etc/janus/"

# Checkinstalkl
sudo -k checkinstall \
  --install=no \
  --pkgsource="https://github.com/shield-ai/janus-gateway" \
  --pkglicense="LGPL 2.1" \
  --deldesc=no \
  --nodoc \
  --maintainer="$USER@shield.ai" \
  --pkgarch="$(dpkg --print-architecture)" \
  --pkgversion=$VERSION \
  --pkgrelease="stable" \
  --pkgname=janus-gateway \
  --include=shieldconfigs \
  --requires="libmicrohttpd-dev,libjansson-dev,libnice-dev,libssl-dev,libsrtp-dev,libsofia-sip-ua-dev,libglib2.0-dev,libopus-dev,libogg-dev,libini-config-dev,libcollection-dev,pkg-config,gengetopt,libtool,automake,dh-autoreconf,libwebsockets-dev" \
  make install

dpkg -x janus-gateway_${VERSION}-stable_amd64.deb temp
cp -r shieldconfigs/* temp/opt/janus/etc/janus/
dpkg -e janus-gateway_${VERSION}-stable_amd64.deb temp/DEBIAN
dpkg -b temp janus-gateway-shield_${VERSION}-stable_amd64.deb
