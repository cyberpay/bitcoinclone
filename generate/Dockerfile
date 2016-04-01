FROM debian:jessie

WORKDIR /root/

COPY run.sh /root/
COPY get_pub_key.py /root/

RUN echo 'deb-src ftp://ftp.us.debian.org/debian/ sid main contrib non-free' >> /etc/apt/sources.list && \
    apt-get update && \
    apt-get build-dep -y \
        bitcoin && \
    apt-get --install-recommends install -y \
        libbitcoin-dev && \
    apt-get install -y \
        vim \
        git && \
    rm -rf /var/lib/apt/lists/* && \
    \
    cd $HOME && \
    git clone https://github.com/derrend/bitcoinclone.git && \
    \
    cd $HOME/bitcoinclone && \
    autoreconf --install && \
    aclocal && \
    automake --add-missing && \
    ./configure --with-incompatible-bdb --with-gui=no --with-qrencode=no && \
    make

CMD ["bash", "run.sh"]
