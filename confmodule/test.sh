#!/bin/bash

#echo "DEBIAN_HAS_FRONTEND: $DEBIAN_HAS_FRONTEND"

echo "BASHPID (test.sh, before source confmoule): $BASHPID" >&2

source $PWD/confmodule
#source /usr/share/debconf/confmodule

echo "BASHPID (test.sh, after source confmoule): $BASHPID"
echo "DEBIAN_HAS_FRONTEND: $DEBIAN_HAS_FRONTEND"
echo "DEBCONF_REDIR: $DEBCONF_REDIR"
echo ""
echo "Because frontend has been setup, this script can communicate with Debconf"
echo "via command wrappers."
echo ""

set | grep db_

#db_input medium foo/like_debian || true
db_get apt-setup/volatile_host
echo $RET
