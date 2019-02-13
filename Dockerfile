FROM node:slim

ARG BUILD_DATE=20190213

#设置环境变量
ENV TIMEZONE="Asia/Shanghai" \
    GITBOOK_VERSION="3.2.3" \
    LC_ALL="zh_CN.utf8"

LABEL build-date=$BUILD_DATE \
      schema-version="1.0.0-rc1" \
      MAINTAINER_MAIL="zdl0812@163.com"

RUN apt-get update \
    && apt-get install -y calibre git locales ttf-wqy-zenhei ttf-wqy-microhei\
    && apt-get clean \
    && npm install gitbook-cli -g \
    && gitbook fetch ${GITBOOK_VERSION} \
    && npm cache verif \
    && npm cache clear --force \
    && rm -rf /tmp/* \
    && rm -rf /etc/localtime \
    && ln -s /usr/share/zoneinfo/${TIMEZONE} /etc/localtime \
    && alias ls="ls --color" \
    ;

ENV PDF_NAME Book.pdf

VOLUME ["/gitbook", "/pdf"]

WORKDIR /gitbook

EXPOSE 4000
