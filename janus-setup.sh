#!/bin/sh

# assuming this script is in the janus-gateway directory

# dependencies
apt-get update
apt-get --assume-yes install libmicrohttpd-dev libjansson-dev libnice-dev \
    libssl-dev libsrtp-dev libsofia-sip-ua-dev libglib2.0-dev libopus-dev \
    libogg-dev libini-config-dev libcollection-dev pkg-config gengetopt \
    libtool automake dh-autoreconf

# build libwebsockets
cd libwebsockets
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX:PATH=/usr -DCMAKE_C_FLAGS="-fpic" ..
make && sudo make install
cd ../..

# build janus-gateway
sh autogen.sh
./configure --disable-data-channels --disable-rabbitmq --disable-mqtt --prefix=/opt/janus
make
make install

# copy our config files:
cp ./shieldconfigs/*.cfg /opt/janus/etc/janus/
cp ./shieldconfigs/janus.sh /opt/janus/

# add janus executable as cron job on startup
crontab -u -l > mycron
"@reboot /opt/janus/janus.sh" >> mycron
crontab -u mycron
rm mycron
