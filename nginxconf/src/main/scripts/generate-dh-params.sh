#!/bin/sh

numbits=${1:-4096}
outpem=${2:-/etc/nginx/ssl/dhparam.pem}

openssl dhparam -out $outpem $numbits
