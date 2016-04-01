#!/bin/bash

# Capture the suggested rpcpassword paramiter from the uninitialised warning message
$HOME/bitcoinclone/src/bitcoind 2> $HOME/credentials.txt || true && \
grep rpcpassword= $HOME/credentials.txt >> $HOME/.bitcoin/bitcoin.conf

# Capture ip components
IP_PT1=$(grep $HOSTNAME /etc/hosts | cut -f 1 | cut -f 1-3 -d .)
IP_PT2=$(expr $(grep $HOSTNAME /etc/hosts | cut -f 1 | cut -f 4 -d .) - 1)
IP_PT3=$(expr $(grep $HOSTNAME /etc/hosts | cut -f 1 | cut -f 4 -d .) + 1)

# Connent forward if no response from lower ip else connect to lower ip
ping -c 1 $IP_PT1.$IP_PT2 > /dev/null
if [ $? -eq 0 ]; then {
    echo "connect=$IP_PT1.$IP_PT2" >> $HOME/.bitcoin/bitcoin.conf
    }
else {
    echo "connect=$IP_PT1.$IP_PT3" >> $HOME/.bitcoin/bitcoin.conf
    } fi

# Start bitcoin and connect to debug log
$HOME/bitcoinclone/src/bitcoind -debug &
tail -f $HOME/.bitcoin/debug.log

