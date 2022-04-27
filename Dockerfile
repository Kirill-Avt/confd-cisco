FROM amd64/debian:bullseye
MAINTAINER Roman E. Chechnev <roman.chechnev@spacebridge.com>

ENV DEBIAN_FRONTEND=noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN=true

ARG UNAME=devel
ARG UID=1000
ARG GID=1000

RUN echo "---- UID: $UID, GID: $GID ----"

ADD sources /sources/
RUN rm -f /etc/apt/apt.conf.d/docker-clean; echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache

RUN echo "deb http://deb.debian.org/debian bullseye main" > /etc/apt/sources.list.d/bullseye.list
RUN echo "deb http://deb.debian.org/debian experimental main" > /etc/apt/sources.list.d/experimental.list

RUN apt-get update
# RUN apt-get -y install npm
# install basic dependencies (bindings, for sysrepo lib, general tools, libyang)
#RUN apt-get -y dist-upgrade
RUN rm -rf /var/lib/apt/lists/*
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked --mount=type=cache,target=/var/lib/apt,sharing=locked \
/sources/dataplane-sdk/bin/dataplane_sdk_setup

RUN groupadd -f -g $GID $UNAME
RUN useradd -m -u $UID -g $GID -o -s /bin/bash $UNAME

RUN echo $UNAME:$UNAME | chpasswd
RUN echo "$UNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

ADD https://github.com/Kirill-Avt/confd-cisco/blob/main/confd-basic-7.5.3.linux.x86_64.installer.bin?raw=true /usr/local/bin/confd
RUN chmod +x /usr/local/bin/confd
RUN mkdir /usr/local/bin/confdc
RUN /usr/local/bin/confd /usr/local/bin/confdc
RUN cp -r /usr/local/bin/confdc/bin/confdc /usr/bin/
RUN cp -r /usr/local/bin/confdc/lib/confd /usr/lib/
RUN cp -r /usr/local/bin/confdc/lib/cs2yang /usr/lib/
RUN cp -r /usr/local/bin/confdc/lib/pyang /usr/lib/
RUN cp /usr/local/bin/confdc/lib/libconfd.a /usr/lib/
RUN cp /usr/local/bin/confdc/lib/libconfd.so /usr/lib/
RUN cp -r /usr/local/bin/confdc/src/confd /usr/src
RUN cp -r /usr/local/bin/confdc/var/confd /usr/var
RUN cp -r /usr/local/bin/confdc/etc/confd /usr/etc

## run without cache
ARG CACHEBUST=1
RUN /sources/dataplane-sdk/bin/dataplane_sdk_setup_project /sources/dataplane-sdk-project/

# use /opt/dev as working directory
#RUN mkdir /opt/dev
#WORKDIR /opt/dev

