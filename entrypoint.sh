#!/usr/bin/env bash

set -x 

update-crypto-policies --show

envsubst < stunnel.conf.tmpl > stunnel.conf

stunnel stunnel.conf

