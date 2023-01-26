FROM alpine:3.17.1

LABEL org.opencontainers.image.authors="nttdata"

RUN apk update && apk upgrade && apk add --no-cache \
  nodejs

WORKDIR /app