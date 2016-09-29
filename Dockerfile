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
    curl http://srv70.putdrive.com/putstorage/DownloadFileHash/5CC5AFA03A5A4A5QQWE2175047EWQS/iib-10.0.0.6.tar | tar zx --exclude iib-10.0.0.6/tools --directory /opt/ibm 

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

