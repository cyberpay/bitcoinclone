#!/bin/bash
docker pull derrend/bitcoinclone && \
docker run -it --name seed derrend/bitcoinclone && \
docker commit seed derrend/bitcoinclone:altcoin && \
docker rm seed && \
cd deployment_extention/ && \
docker build -t derrend/bitcoinclone:altcoin . && \
docker -d --name node_1 derrend/bitcoinclone:altcoin && \
docker -it --name node_2 derrend/bitcoinclone:altcoin
