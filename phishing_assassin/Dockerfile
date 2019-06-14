#####    PhishingAssassin Dockerfile    #####



## --- Import origin image --- ##
FROM debian:9


## --- Update repositories and install SpamAssassin --- ##
RUN apt-get update && \
    apt-get install -y spamassassin


## --- Install Perl libraries needed to execute new Anti-Phishing Plugins --- ##
# No one needed yet!


## --- Empty default Anti-Spam Rules and Plugins --- ##
# Rules (.cf)
RUN rm -rf /usr/share/spamassassin/*
# Plugins (.pm)
RUN rm -rf /usr/share/perl5/Mail/SpamAssassin/Plugin/*
# Plugin load configuration (.pre)
RUN rm -rf /etc/mail/spamassassin/*


## --- Add source files --- ##
# Default base Rules
COPY ./rules/10_default_prefs.cf /usr/share/spamassassin
# Default base Plugins
COPY ./plugins/Check.pm /usr/share/perl5/Mail/SpamAssassin/Plugin
# Load Default base Plugins
COPY ./plugin_load/v320.pre /etc/mail/spamassassin

# Anti-Phishing Rules
COPY ./rules/antiphishing.cf /etc/mail/spamassassin
# Anti-Phishing Plugins
COPY ./plugins/AntiPhishing.pm /etc/mail/spamassassin
# Load Anti-Phishing Plugins
COPY ./plugin_load/antiphishing.pre /etc/mail/spamassassin


## --- Open port --- ##
EXPOSE 783/tcp


## --- Allowed Client IPs defined by User during building stage in command line--- ##
ARG ALLOWED_CLIENT_IPS


## --- Execute on start --- ##
ENTRYPOINT spamd --listen-ip=0.0.0.0 --port=783 --allowed-ips=$ALLOWED_CLIENT_IPS --debug