# syntax=docker/dockerfile:1
FROM alpine:latest AS build

ARG awscli2_url=https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip
ARG alpine_glibc=https://api.github.com/repos/sgerrand/alpine-pkg-glibc/releases/latest
ARG sgerrand_glibc=https://github.com/sgerrand/alpine-pkg-glibc/releases/download

RUN apk add --update --no-cache \
    bash \
    binutils \
    curl \
    grep \
    jq \
    python3 \
    && GLIBC_VER=$(curl -s ${alpine_glibc} | grep tag_name | cut -d : -f 2,3 | tr -d '", ') \
    && curl -sL https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub -o /etc/apk/keys/sgerrand.rsa.pub \
    && curl -sLO ${sgerrand_glibc}/${GLIBC_VER}/glibc-${GLIBC_VER}.apk \
    && curl -sLO ${sgerrand_glibc}/${GLIBC_VER}/glibc-bin-${GLIBC_VER}.apk \
    && apk add --no-cache \
    glibc-${GLIBC_VER}.apk \
    glibc-bin-${GLIBC_VER}.apk \
    && curl -sL ${awscli2_url} -o awscliv2.zip \
    && unzip awscliv2.zip \
    && aws/install \
    && rm -rf \
    awscliv2.zip \
    aws \
    /usr/local/aws-cli/v2/*/dist/aws_completer \
    /usr/local/aws-cli/v2/*/dist/awscli/data/ac.index \
    /usr/local/aws-cli/v2/*/dist/awscli/examples \
    && apk --no-cache del \
    binutils \
    curl

COPY manager/ /

ENTRYPOINT ["/run.sh"]
