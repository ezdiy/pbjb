# Set up build stage 
FROM ubuntu:18.04 AS buildstage
ENV DEBIAN_FRONTEND=noninteractive TZ=Europe/Amsterdam

RUN dpkg --add-architecture i386

RUN apt-get update && \
    apt-get -y install zip wget git build-essential make \
    libc6:i386 libncurses5:i386 libstdc++6:i386 

ENV ROOTDIR=/pocketbook-jailbreak
WORKDIR ${ROOTDIR}

RUN wget https://toolchains.bootlin.com/downloads/releases/toolchains/armv7-eabihf/tarballs/armv7-eabihf--musl--stable-2018.11-1.tar.bz2
RUN tar -xvf armv7-eabihf--musl--stable-2018.11-1.tar.bz2

RUN wget https://github.com/ezdiy/pocketbook-sdk5/archive/master.tar.gz
RUN tar -xvf master.tar.gz

ENV PATH="${ROOTDIR}/pocketbook-sdk5-master/bin:${ROOTDIR}/armv7-eabihf--musl--stable-2018.11-1/bin:${PATH}"

WORKDIR /pbjb

CMD make
