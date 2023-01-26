ARG IMAGE
FROM ${IMAGE}

# instalando paquetes
RUN apk update && apk upgrade && apk add --no-cache bash curl

# instalando github-cli
RUN echo "@community http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories
RUN apk add --no-cache github-cli@community

COPY docker/gh/init.sh /root/init.sh
CMD [ "/root/init.sh" ]