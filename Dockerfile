# Set up build stage 
FROM ubuntu:18.04 AS buildstage
ENV DEBIAN_FRONTEND=noninteractive TZ=Europe/Amsterdam

RUN dpkg --add-architecture i386

RUN apt-get update && \
    apt-get -y install dh-autoreconf zip wget git build-essential make \
    libc6:i386 libncurses5:i386 libstdc++6:i386 

ENV ROOTDIR=/pocketbook-jailbreak
WORKDIR ${ROOTDIR}

RUN wget https://toolchains.bootlin.com/downloads/releases/toolchains/armv7-eabihf/tarballs/armv7-eabihf--musl--stable-2018.11-1.tar.bz2
RUN tar -xvf armv7-eabihf--musl--stable-2018.11-1.tar.bz2
RUN rm armv7-eabihf--musl--stable-2018.11-1.tar.bz2

RUN wget https://github.com/ezdiy/pocketbook-sdk5/archive/master.tar.gz
RUN tar -xvf master.tar.gz
RUN rm master.tar.gz

RUN wget https://releases.linaro.org/archive/15.05/components/toolchain/binaries/arm-linux-gnueabihf/gcc-linaro-4.9-2015.05-x86_64_arm-linux-gnueabihf.tar.xz
RUN tar -xvf gcc-linaro-4.9-2015.05-x86_64_arm-linux-gnueabihf.tar.xz
RUN rm gcc-linaro-4.9-2015.05-x86_64_arm-linux-gnueabihf.tar.xz

ENV PATH="${ROOTDIR}/pocketbook-sdk5-master/bin:${ROOTDIR}/armv7-eabihf--musl--stable-2018.11-1/bin:${ROOTDIR}/gcc-linaro-4.9-2015.05-x86_64_arm-linux-gnueabihf/bin:${PATH}"

WORKDIR /pbjb

CMD make
