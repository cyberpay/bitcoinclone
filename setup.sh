#!/bin/bash

# Pull the precompiled bitcoinclone container, run it and save the
# result
docker pull derrend/bitcoinclone && \
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
