ARG ALPINE_VERSION=3.8

########################
# Build And Install #
########################
FROM alpine:$ALPINE_VERSION as build
LABEL MAINTAINER_MAIL="zdl0812@163.com" \
      ALPINE_VERSION="3.8" \
      GITBOOK_VERSION="2.6.7+latest"

ENV GLIBC_VERSION="2.28-r0" \
    TIMEZONE="Asia/Shanghai" \
    PS1="[\u@\w] \$"

# Download and install glibc
RUN apk add --no-cache \
        curl && \
    curl -k -Lo /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub && \
    curl -k -Lo glibc.apk "https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk" && \
    curl -k -Lo glibc-bin.apk "https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-bin-${GLIBC_VERSION}.apk" && \
    apk add glibc-bin.apk glibc.apk && \
    /usr/glibc-compat/sbin/ldconfig /lib /usr/glibc-compat/lib && \
    # echo 'hosts: files mdns4_minimal [NOTFOUND=return] dns mdns4' >> /etc/nsswitch.conf && \
    rm -rf glibc.apk glibc-bin.apk /var/cache/apk/*

# Download and install calibre
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/calibre/lib \
    PATH=/opt/calibre/bin:$PATH \
    CALIBRE_INSTALLER_SOURCE_CODE_URL=https://raw.githubusercontent.com/kovidgoyal/calibre/master/setup/linux-installer.py
    
RUN apk add --no-cache \
    # bash \
    ca-certificates \
    python \
    xdg-utils \
    gcc \
    mesa-gl \
    xz-dev \
    xz \
    nodejs \
    npm \
    tzdata \
    ;
    
# set timezone && create /opt
RUN mkdir /opt \
    && rm -rf /etc/localtime \
    && ln -s /usr/share/zoneinfo/${TIMEZONE} /etc/localtime
    
WORKDIR /opt
    
RUN curl -k -L https://download.calibre-ebook.com/linux-installer.sh | sh /dev/stdin install_dir=/opt isolated=y &&\
    # curl -k -L ${CALIBRE_INSTALLER_SOURCE_CODE_URL} -o linux-installer.py &&\
    # python linux-installer.py &&\
    # rm -rf /tmp/calibre-installer-cache &&\
    rm -rf /var/cache/apk/*
    
RUN npm install gitbook-cli -g &&\
    gitbook fetch &&\
    gitbook fetch 2.6.7 &&\
    rm -rf /var/cache/apk/*
    
EXPOSE 4000
