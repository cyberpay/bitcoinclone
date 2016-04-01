#!/usr/bin/env bash

# Set veriables
DATA_TIMESTAMP=1397080064
NEW_DATA_TIMESTAMP=$(date +%s)
DATATESTNET_TIMESTAMP=1337966069
NEW_DATATESTNET_TIMESTAMP=$(expr $(date +%s) - 90)

MAIN_VALERTPUBKEY="04fc9702847840aaf195de8442ebecedf5b095cdbb9bc716bda9110971b28a49e0ead8564ff0db22209e0374782c093bb899692d524e9d6a6956e7c5ecbcd68284"
TEST_VALERTPUBKEY="04302390343f91cc401d56d68b123028bf52e5fca1939df127f63c6467cdf9c8e2c14b61104cf817d0b780da337893ecc4aaff1309e536162dabbdb45200ca2b0a"

SCRIPT_PUB_KEY="04678afdb0fe5548271967f1a67130b7105cd6a828e03909a67962e0ea1f61deb649f6bc3f4cef38c4f35504e51ec112de5c384df7ba0b8d578a4c702b6bf11d5f"

MAIN_GENESIS_NTIME=1231006505
TEST_GENESIS_NTIME=1296688602

MAINNET_MERKLE_ROOT="4a5e1e4baab89f3a32518a88c31bc87f618f76673e2cc77ab2127b7afdeda33b"

MAINNET_NONCE=2083236893
TESTNET_NONCE=414098458

MAINNET_GENESIS_HASH="000000000019d6689c085ae165831e934ff763ae46a2a6c172b3f1b60a8ce26f"
TESTNET_GENESIS_HASH="000000000933ea01ad0ee984209779baaec3ced90fa3f408719526f8d77f4943"
REGTESTNET_GENESIS_HASH="0f9188f13cb7b2c71f2a335e3a4fc328bf5beb436012afca590b1a11466e2206"

# Generate key pairs and convert to hex format
mkdir $HOME/key_files/
cd $HOME/key_files/
openssl ecparam -genkey -name secp256k1 -out alertkey.pem
openssl ec -in alertkey.pem -text > alertkey.hex
openssl ecparam -genkey -name secp256k1 -out testnetalert.pem
openssl ec -in testnetalert.pem -text > testnetalert.hex
openssl ecparam -genkey -name secp256k1 -out genesiscoinbase.pem
openssl ec -in testnetalert.pem -text > genesiscoinbase.hex
wait

# Update timestamps
find $HOME/bitcointemplate/src/ -name chainparams.cpp -print0 | xargs -0 sed -i \
    "s/$DATA_TIMESTAMP/$NEW_DATA_TIMESTAMP/g"
find $HOME/bitcointemplate/src/ -name chainparams.cpp -print0 | xargs -0 sed -i \
    "s/$DATATESTNET_TIMESTAMP/$NEW_DATATESTNET_TIMESTAMP/g"
find $HOME/bitcointemplate/src/ -name chainparams.cpp -print0 | xargs -0 sed -i \
    "s/$MAIN_GENESIS_NTIME/$NEW_DATA_TIMESTAMP/g"
find $HOME/bitcointemplate/src/ -name chainparams.cpp -print0 | xargs -0 sed -i \
    "s/$TEST_GENESIS_NTIME/$NEW_DATATESTNET_TIMESTAMP/g"

# Update alert keys
find $HOME/bitcointemplate/src/ -name chainparams.cpp -print0 | xargs -0 sed -i \
    "s/$MAIN_VALERTPUBKEY/$(python $HOME/get_pub_key.py $HOME/key_files/alertkey.hex)/g"
find $HOME/bitcointemplate/src/ -name chainparams.cpp -print0 | xargs -0 sed -i \
    "s/$TEST_VALERTPUBKEY/$(python $HOME/get_pub_key.py $HOME/key_files/testnetalert.hex)/g"

# Update script pub key
find $HOME/bitcointemplate/src/ -name chainparams.cpp -print0 | xargs -0 sed -i \
    "s/$SCRIPT_PUB_KEY/$(python $HOME/get_pub_key.py $HOME/key_files/genesiscoinbase.hex)/g"

# Update magic bytes
find $HOME/bitcointemplate/src/ -name chainparams.cpp -print0 | xargs -0 sed -i \
    "s/pchMessageStart\[0\] =/pchMessageStart\[0\] = 0x$(printf "%x\n" $(shuf -i 0-255 -n 1)); \/\//g"
find $HOME/bitcointemplate/src/ -name chainparams.cpp -print0 | xargs -0 sed -i \
    "s/pchMessageStart\[1\] =/pchMessageStart\[1\] = 0x$(printf "%x\n" $(shuf -i 0-255 -n 1)); \/\//g"
find $HOME/bitcointemplate/src/ -name chainparams.cpp -print0 | xargs -0 sed -i \
    "s/pchMessageStart\[2\] =/pchMessageStart\[2\] = 0x$(printf "%x\n" $(shuf -i 0-255 -n 1)); \/\//g"
find $HOME/bitcointemplate/src/ -name chainparams.cpp -print0 | xargs -0 sed -i \
    "s/pchMessageStart\[3\] =/pchMessageStart\[3\] = 0x$(printf "%x\n" $(shuf -i 0-255 -n 1)); \/\//g"

# Compile
cd $HOME/bitcointemplate
make

# Mine mainnet genesis block
mkdir $HOME/mined_blocks
cd $HOME/bitcointemplate/src
clear

cat <<EOF
--------
Mining mainnet genesis block.
Began mining $(date)

This could take up to four hours, perhaps even longer depending on your hardware.
--------
EOF

./bitcoind > $HOME/mined_blocks/mainnet_info.txt
wait

# Update mainnet genesis block paramiters
find $HOME/bitcointemplate/src/ -name chainparams.cpp -print0 | xargs -0 sed -i \
    "s/$MAINNET_MERKLE_ROOT/$(grep 'new mainnet genesis merkle root:' $HOME/mined_blocks/mainnet_info.txt | cut -f 2 -d ':' | xargs)/g"
find $HOME/bitcointemplate/src/ -name chainparams.cpp -print0 | xargs -0 sed -i \
    "s/$MAINNET_NONCE/$(grep 'new mainnet genesis nonce:' $HOME/mined_blocks/mainnet_info.txt | cut -f 2 -d ':' | xargs)/g"
find $HOME/bitcointemplate/src/ -name chainparams.cpp -print0 | xargs -0 sed -i \
    "s/$MAINNET_GENESIS_HASH/$(grep 'new mainnet genesis hash:' $HOME/mined_blocks/mainnet_info.txt | cut -f 2 -d ':' | xargs)/g"

# Initialize hashGenesisBlock value for mainnet
find $HOME/bitcointemplate/src/ -name chainparams.cpp -print0 | xargs -0 sed -i \
    "0,/hashGenesisBlock == uint256(\"0x01\")/{s/hashGenesisBlock == uint256(\"0x01\")/hashGenesisBlock == uint256(\"0x$(grep 'new mainnet genesis hash:' $HOME/mined_blocks/mainnet_info.txt | cut -f 2 -d ':' | xargs)\")/}"

# Switch off the mainnet genesis mining function
find $HOME/bitcointemplate/src/ -name chainparams.cpp -print0 | xargs -0 sed -i \
    "0,/if (true/{s/if (true/if (false/}"

# Compile again
cd $HOME/bitcointemplate
make

# Mine testnet genesis block
cd $HOME/bitcointemplate/src
clear

cat <<EOF
--------
Mining testnet genesis block.
Began mining $(date)

This could take up to four hours, perhaps even longer depending on your hardware.
--------
EOF

./bitcoind > $HOME/mined_blocks/testnet_info.txt
wait

# Update testnet genesis block paramiters
find $HOME/bitcointemplate/src/ -name chainparams.cpp -print0 | xargs -0 sed -i \
    "s/$TESTNET_NONCE/$(grep 'new testnet genesis nonce:' $HOME/mined_blocks/testnet_info.txt | cut -f 2 -d ':' | xargs)/g"
find $HOME/bitcointemplate/src/ -name chainparams.cpp -print0 | xargs -0 sed -i \
    "s/$TESTNET_GENESIS_HASH/$(grep 'new testnet genesis hash:' $HOME/mined_blocks/testnet_info.txt | cut -f 2 -d ':' | xargs)/g"

# Initialize hashGenesisBlock value for testnet
find $HOME/bitcointemplate/src/ -name chainparams.cpp -print0 | xargs -0 sed -i \
    "0,/hashGenesisBlock == uint256(\"0x01\")/{s/hashGenesisBlock == uint256(\"0x01\")/hashGenesisBlock == uint256(\"0x$(grep 'new testnet genesis hash:' $HOME/mined_blocks/testnet_info.txt | cut -f 2 -d ':' | xargs)\")/}"

# Switch off the testnet genesis mining function
find $HOME/bitcointemplate/src/ -name chainparams.cpp -print0 | xargs -0 sed -i \
    "0,/if (true/{s/if (true/if (false/}"

# Compile for a third time
cd $HOME/bitcointemplate
make

# Mine regtestnet genesis block
cd $HOME/bitcointemplate/src
clear

cat <<EOF
--------
Mining regtestnet genesis block.
Began mining $(date)

This could take up to four hours, perhaps even longer depending on your hardware.
--------
EOF

./bitcoind > $HOME/mined_blocks/regtestnet_info.txt
wait

# Update regtestnet genesis block paramiters
find $HOME/bitcointemplate/src/ -name chainparams.cpp -print0 | xargs -0 sed -i \
    "s/genesis.nNonce = 2/genesis.nNonce = $(grep 'new regtestnet genesis nonce:' $HOME/mined_blocks/regtestnet_info.txt | cut -f 2 -d ':' | xargs)/g"
find $HOME/bitcointemplate/src/ -name chainparams.cpp -print0 | xargs -0 sed -i \
    "s/$REGTESTNET_GENESIS_HASH/$(grep 'new regtestnet genesis hash:' $HOME/mined_blocks/regtestnet_info.txt | cut -f 2 -d ':' | xargs)/g"

# Initialize hashGenesisBlock value for regtestnet
find $HOME/bitcointemplate/src/ -name chainparams.cpp -print0 | xargs -0 sed -i \
    "0,/hashGenesisBlock == uint256(\"0x01\")/{s/hashGenesisBlock == uint256(\"0x01\")/hashGenesisBlock == uint256(\"0x$(grep 'new regtestnet genesis hash:' $HOME/mined_blocks/regtestnet_info.txt | cut -f 2 -d ':' | xargs)\")/}"

# Switch off the regtestnet genesis mining function
find $HOME/bitcointemplate/src/ -name chainparams.cpp -print0 | xargs -0 sed -i \
    "0,/if (true/{s/if (true/if (false/}"

# Final compile
cd $HOME/bitcointemplate
make

# Closing statement
clear
cat <<EOF
--------
Your new clone is ready to go.

Next steps,
Commit your new clone, be sure to save it as 'bitcoinclone:altcoin':

    docker commit <container_name> bitcoinclone:altcoin

If you haven't already, clone the bitcoinclone git repo:

    git clone https://github.com/derrend/bitcoinclone.git

Relocate to the deployment_extention folder:

    cd bitcoinclone/deployment_extention

Update the config file to your specifications with your favorite text
editor if you need to:

    vi bitcoin.conf

Build a new easy to deploy image from 'bitcoinclone:altcoin' (this is
why the image name was specified earlier), you can even overwirte the
image we are building from to save space since it has no further use:

    docker build -t bitcoinclone:altcoin .

Begin deploying nodes. You will need to spawn at least two to form a
network:

    docker run -it --name node_1 bitcoinclone:altcoin
    docker run -it --name node_2 bitcoinclone:altcoin

Images may also be run in daemon mode:

    docker run -d --name node_1 bitcoinclone:altcoin
    docker run -d --name node_2 bitcoinclone:altcoin

Enjoy!
--------
EOF
