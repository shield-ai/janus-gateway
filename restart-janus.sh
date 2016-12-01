#!/bin/sh

pkill janus
/opt/janus/bin/janus -F /opt/janus/etc/janus/ &>/dev/null &disown
