#####    PhishingAssassin's Test Dockerfile    #####

## --- Import origin image --- ##
FROM debian:9


## --- Update repositories, install Spamc and create directories --- ##
RUN apt-get update && \
    apt-get install -y spamc &&\
    mkdir /root/dataset

## --- Add files --- ##
# Ascii_art header
COPY ./ascii_art.txt /root

## --- Execute on start --- ##
ENTRYPOINT /root/run_test.sh