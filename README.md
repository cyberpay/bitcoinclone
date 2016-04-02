# bitcoinclone
Spawn and distribute blockchain networks on the fly. Based on bitcoin 0.10.

## Dependencies
[git](https://git-scm.com/downloads "git client"),
[docker](https://docs.docker.com/engine/installation/ "docker engine")

## Instructions
Clone the bitcoinclone repo and run the setup script.

    git clone https://github.com/derrend/bitcoinclone.git && \
    cd bitcoinclone && \
    bash setup.sh
Once the genesis block is mined and the deployment_extention wrapper has been applied (the setup script takes care of all this) you will find a new image inside your local repository named `derrend/bitcoinclone:altcoin`.

Run at least two instances of this image to establish a network. You may deploy as many instances as you wish.

    docker run -d --name node_1 derrend/bitcoinclone:altcoin && \
    docker run -it --name node_2 derrend/bitcoinclone:altcoin
## Important
IP addresses are deterministic in docker and so each new instance is set to connect to its own IP address - 1. If it fails to receive a response it will connect to its own IP address + 1.

You can add IP addresses manually in `deployment_extention/bitcoin.conf`
