FROM bitcoinclone:altcoin

WORKDIR /root/

RUN mkdir $HOME/.bitcoin/ && \
    rm /root/run.sh

COPY bitcoin.conf /root/.bitcoin/
COPY run.sh /root/

CMD ["bash", "/root/run.sh"]
