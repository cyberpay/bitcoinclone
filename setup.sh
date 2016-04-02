#!/bin/bash

clear
cat <<EOF
--------
You can either download the bitcoinclone prebuilt container from dockerhub
or you can build it from the 'generator' template folder (perhaps you
have made some customisations?).
--------

EOF

echo -n "Would you like to download the 2GB image from the repository?
Y/N: "
read CHOICE
if [ $CHOICE == "Y" ] || [ $CHOICE == "y" ] || [ $CHOICE == "Yes" ] || [ $CHOICE == "yes" ]; then {
    docker pull derrend/bitcoinclone
    wait
    }
else {
    cd generator/ && \
    docker build -t derrend/bitcoinclone . && \
    cd ..
    } fi

# Pull the precompiled bitcoinclone container, run it and save the
# result
docker run -it --name seed derrend/bitcoinclone && \
docker commit seed derrend/bitcoinclone:altcoin && \
docker rm seed && \
\
# Move into the deployment_extention directory 
cd deployment_extention/ && \
# if you wish to make customisations to your bitcoin.conf, do it now.
\
# Issue a build command to overwrite the existiag clone with some new
# wrapper scripts.
docker build -t derrend/bitcoinclone:altcoin . && \
\
# Spawn two instances of the completed clone to form a two node network.
# You may spawn as many nodes as you wish.
docker run -d --name node_1 derrend/bitcoinclone:altcoin && \
docker run -it --name node_2 derrend/bitcoinclone:altcoin
