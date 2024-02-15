#!/bin/sh

NAME=jdimpson/masscan

#NETWORK='';
NETWORK='--net=host';
#NETWORK='--net=macvlan0';

docker run -it --rm $NETWORK "$NAME" $*
