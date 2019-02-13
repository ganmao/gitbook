ARG ALPINE_VERSION=3.8

########################
# Build And Install #
########################
FROM alpine:$ALPINE_VERSION
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
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/glibc-compat/lib:/usr/lib/:/opt/calibre/lib \
    PATH=$PATH:/opt/calibre/bin \
    CALIBRE_INSTALLER_SOURCE_CODE_URL=https://raw.githubusercontent.com/kovidgoyal/calibre/master/setup/linux-installer.py
    
RUN apk add --no-cache --upgrade \
    bash \
    ca-certificates \
    gcc \
    mesa-gl \
    python \
    qt5-qtbase-x11 \
    xdg-utils \
    xz \
    nodejs \
    npm \
    tzdata \
    ;
    
# set timezone && create /opt /gitbook
RUN mkdir /opt /gitbook \
    && rm -rf /etc/localtime \
    && ln -s /usr/share/zoneinfo/${TIMEZONE} /etc/localtime
    
RUN curl -k -L ${CALIBRE_INSTALLER_SOURCE_CODE_URL} | python -c "import sys; main=lambda:sys.stderr.write('Download failed\n'); exec(sys.stdin.read()); main(install_dir='/opt', isolated=True)" && \
    rm -rf /tmp/calibre-installer-cache &&\
    rm -rf /var/cache/apk/*
    
RUN npm install gitbook-cli -g &&\
    gitbook fetch &&\
    gitbook fetch 2.6.7
    
WORKDIR /gitbook
    
EXPOSE 4000
