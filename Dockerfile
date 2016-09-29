# © Copyright IBM Corporation 2015.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html

FROM ubuntu:14.04

MAINTAINER Joerg Wende

# Install curl
RUN apt-get update && \
    apt-get install -y curl && \
    rm -rf /var/lib/apt/lists/*

RUN apt-get update && \
	apt-get dist-upgrade -y
	

# Install IIB V10 Developer edition
RUN mkdir /opt/ibm && \
    curl https://download.wetransfer.com/eu2/37fafc73a391672b082c5e0e751e5c8620160929085700/10.0.0-IIB-LINUXX64-FP0006.tar.gz?escaped=false&expiration=1475140592&callback={"formdata":{"action":"https://api.wetransfer.com/api/v1/transfers/37fafc73a391672b082c5e0e751e5c8620160929085700/recipients/71c978d9157bd219c8e34391a958b8ce20160929085700"},"form":{"status":["param","status"],"download_id":"1727720822"}}&signature=e44145491ef3f7aa00e2046e8ed8aa9c0a0d7827ca743d812cae360740646742 | tar zx --exclude iib-10.0.0.5/tools --directory /opt/ibm 

# Configure system
COPY kernel_settings.sh /tmp/
RUN echo "IIB_10:" > /etc/debian_chroot  && \
    touch /var/log/syslog && \
    chown syslog:adm /var/log/syslog && \
    chmod +x /tmp/kernel_settings.sh;sync && \
    /tmp/kernel_settings.sh

RUN groupadd --gid 2000 mqbrkrs

# Create user to run as
RUN useradd --uid 2000 --create-home --home-dir /home/iibuser -G mqbrkrs,sudo iibuser && sed -e 's/^%sudo	.*/%sudo	ALL=NOPASSWD:ALL/g' -i /etc/sudoers	

# Copy in script files
COPY iib_manage.sh /usr/local/bin/
COPY iib-license-check.sh /usr/local/bin/
COPY iib_env.sh /usr/local/bin/
COPY login.defs /etc/login.defs
RUN chmod +rx /usr/local/bin/*.sh

# Set BASH_ENV to source mqsiprofile when using docker exec bash -c
# ENV BASH_ENV=/usr/local/bin/iib_env.sh

USER iibuser

# Expose default admin port and http port
EXPOSE 4414 7800
	
VOLUME /var/mqsi

# Set entrypoint to run management script
ENTRYPOINT ["iib_manage.sh"]

