FROM neilpang/acme.sh:latest

LABEL cn.magicarnea.description="Ngrok image with letsencrypt certificate signed by acme.sh through cloudfare based on alpine." \
      cn.magicarnea.vendor="MagicArena" \
      cn.magicarnea.maintainer="everoctivian@gmail.com" \
      cn.magicarnea.versionCode=1 \
      cn.magicarnea.versionName="1.0.0"

ARG NGROK_DOMAIN
ARG CF_Account_ID
ARG CF_Token

ENV NGROK_DOMAIN=${NGROK_DOMAIN}
ENV CF_Account_ID=${CF_Account_ID}
ENV CF_Token=${CF_Token}

EXPOSE 80/tcp 443/tcp 4443/tcp

HEALTHCHECK --interval=1m \
            --timeout=3s \
            --start-period=5s \
            --retries=5 \
            CMD nc -z localhost 4443 > /dev/null; if [ 0 != $? ]; then exit 1; fi;

# if you want use APK mirror then uncomment, modify the mirror address to which you favor
#RUN sed -i 's|http://dl-cdn.alpinelinux.org|https://mirrors.aliyun.com|g' /etc/apk/repositories

ENV TIME_ZONE=Asia/Shanghai
RUN set -ex && \
    apk add --no-cache tzdata && \
    ln -snf /usr/share/zoneinfo/${TIME_ZONE} /etc/localtime && \
    echo ${TIME_ZONE} > /etc/timezone && \
    rm -rf /tmp/* /var/cache/apk/*

RUN apk add --no-cache ca-certificates wget build-base curl go git openssl openssl-dev && \
    git clone https://github.com/inconshreveable/ngrok.git /ngrok && cd /ngrok && \
    acme.sh --issue \
            --dns dns_cf \
            -d "*.${NGROK_DOMAIN}" \
            -d ${NGROK_DOMAIN} && \
    acme.sh --install-cert \
            -d "*.${NGROK_DOMAIN}" \
            --cert-file /ngrok/assets/client/tls/ngrokroot.crt \
            --key-file /ngrok/assets/server/tls/snakeoil.key \
            --fullchain-file /ngrok/assets/server/tls/snakeoil.crt && \
    make release-server && \
    GOOS=linux GOARCH=amd64 make release-client && \
    GOOS=darwin GOARCH=amd64 make release-client && \
    GOOS=windows GOARCH=amd64 make release-client && \
    GOOS=windows GOARCH=386 make release-client && \
    apk del wget build-base curl go git openssl openssl-dev && rm -rf /var/cache/apk/*

ENV CF_Account_ID=
ENV CF_Token=

ENTRYPOINT /ngrok/bin/ngrokd \
          -domain=${NGROK_DOMAIN} \
          -tlsKey=/ngrok/assets/server/tls/snakeoil.key \
          -tlsCrt=/ngrok/assets/server/tls/snakeoil.crt \
          -httpAddr=:80 \
          -httpsAddr=:443 \
          -tunnelAddr=:4443 \
          -log=stdout \
          -log-level=DEBUG